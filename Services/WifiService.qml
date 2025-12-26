import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service
    
    property bool isEnabled: false
    property string connectedSSID: ""
    property ListModel networks: ListModel {}
    
    function hasNetwork(ssid) {
        for (let i = 0; i < networks.count; i++) {
            if (networks.get(i).ssid === ssid) return true;
        }
        return false;
    }

    Process {
        id: statusProcess
        command: ["nmcli", "radio", "wifi"]
        
        stdout: SplitParser {
            onRead: data => {
                service.isEnabled = data.trim() === "enabled"
            }
        }
    }
    
    Process {
        id: connectedProcess
        command: ["nmcli", "-t", "-f", "active,ssid", "dev", "wifi"]
        
        stdout: SplitParser {
            onRead: data => {
                const lines = data.split('\n')
                for (const line of lines) {
                    if (line.startsWith('yes:')) {
                        // format is yes:SSID
                        // substring(4) skips "yes:"
                        service.connectedSSID = line.substring(4).trim()
                        break
                    }
                }
            }
        }
    }
    
    Process {
        id: scanProcess
        // Use -t (terse) for script-friendly output (colons instead of spaces)
        // This handles SSIDs with spaces correctly (e.g. "My Home Wifi")
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY", "dev", "wifi", "list"]
        
        stdout: SplitParser {
            onRead: data => {
                const lines = data.split('\n')
                
                for (const line of lines) {
                    if (!line || line.trim() === '') continue
                    const lastColon = line.lastIndexOf(':')
                    const secondLastColon = line.lastIndexOf(':', lastColon - 1)
                    
                    if (lastColon === -1 || secondLastColon === -1) continue

                    const ssid = line.substring(0, secondLastColon).replace(/\\:/g, ':')
                    const signal = parseInt(line.substring(secondLastColon + 1, lastColon)) || 0
                    const security = line.substring(lastColon + 1)
                    
                    if (ssid && ssid !== '--' && !service.hasNetwork(ssid)) {
                        service.networks.append({
                            ssid: ssid,
                            signal: signal,
                            secured: security.length > 0 && security !== ""
                        })
                    }
                }
            }
        }
    }
    
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: service.update()
    }
    
    Timer {
        id: delayedUpdate
        interval: 2000
        onTriggered: service.update()
    }
    
    Component.onCompleted: {
        update()
    }
    
    function update() {
        statusProcess.running = true
        connectedProcess.running = true
        if (isEnabled) {
            networks.clear() 
            scanProcess.running = true
        } else {
            networks.clear()
            service.connectedSSID = ""
        }
    }
    
    function toggleRadio() {
        if (isEnabled) {
            Quickshell.execDetached(["nmcli", "radio", "wifi", "off"])
        } else {
            Quickshell.execDetached(["nmcli", "radio", "wifi", "on"])
        }
        delayedUpdate.start()
    }
    
    function connect(ssid) {
        Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", ssid])
        delayedUpdate.start()
    }
    
    function disconnect() {
        if (service.connectedSSID) {
            Quickshell.execDetached(["nmcli", "connection", "down", service.connectedSSID])
            delayedUpdate.start()
        }
    }
}
