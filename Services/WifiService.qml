import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service
    
    property bool typing: false
    property bool isEnabled: false
    property string connectedSSID: ""
    property ListModel networks: ListModel {}
    property var _scanResults: []
    
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
            onRead: data => service.isEnabled = data.trim() === "enabled"
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
                        service.connectedSSID = line.substring(4).trim()
                        break
                    }
                }
            }
        }
    }
    
    Process {
        id: scanProcess
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY", "dev", "wifi", "list"]
        onStarted: service._scanResults = []
        
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
                    
                    if (ssid && ssid !== '--') {
                        // 2. Add to buffer instead of model directly
                        service._scanResults.push({
                            ssid: ssid,
                            signal: signal,
                            secured: security.length > 0 && security !== ""
                        })
                    }
                }
            }
        }
        onExited: {
            // Remove duplicates from buffer (nmcli returns duplicates for mesh networks)
            const uniqueResults = [];
            const seenSSIDs = new Set();
            
            for (const item of service._scanResults) {
                if (!seenSSIDs.has(item.ssid)) {
                    seenSSIDs.add(item.ssid);
                    uniqueResults.push(item);
                }
            }
            
            for (const newItem of uniqueResults) {
                let foundIndex = -1;
                for (let i = 0; i < networks.count; i++) {
                    if (networks.get(i).ssid === newItem.ssid) {
                        foundIndex = i;
                        break;
                    }
                }
                
                if (foundIndex !== -1) {
                    networks.set(foundIndex, newItem);
                } else {
                    networks.append(newItem);
                }
            }
            
            for (let i = networks.count - 1; i >= 0; i--) {
                const oldSSID = networks.get(i).ssid;
                if (!seenSSIDs.has(oldSSID)) {
                    networks.remove(i);
                }
            }
        }
    }
    
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: service.update()
    }
    
    Timer {
        id: delayedUpdate
        interval: 2000
        onTriggered: service.update()
    }
    
    Component.onCompleted: update()
    
    function update() {
        if (typing) return;
        statusProcess.running = true
        connectedProcess.running = true
        if (isEnabled) {
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
    
    function connect(ssid, password) {
        if (password && password !== "") {
            Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", ssid, "password", password])
        } else {
            Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", ssid])
        }
        delayedUpdate.start()
    }
    
    function disconnect() {
        if (service.connectedSSID) {
            Quickshell.execDetached(["nmcli", "connection", "down", service.connectedSSID])
            delayedUpdate.start()
        }
    }
}
