import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service

    property bool typing: false
    property bool isEnabled: false
    property string connectedSSID: ""
    property ListModel networks: ListModel {}
    
    // Connection state tracking
    property string connectingSSID: ""
    property string connectionError: ""
    property bool isEthernetConnected: false
    property var _scanResults: []
    property var _knownList: []

    Process {
        id: connectionProcess
        stdout: SplitParser {
            onRead: data => console.log("[Connect Out]: " + data)
        }
        stderr: SplitParser {
            onRead: data => {
                console.log("[Connect Err]: " + data)
                // Capture errors
                if (data.includes("Secrets were required") || 
                    data.includes("802-11-wireless-security.psk") ||
                    data.includes("Error:")) {
                    service.connectionError = "invalid";
                }
            }
        }
        onExited: {
            console.log("Connection attempt finished. Exit code: " + exitCode);
            
            if (exitCode !== 0) {
                console.log("Connection failed");
                if (service.connectionError === "") {
                    service.connectionError = "failed";
                }
            }
            
            settleTimer.start();
        }
    }

    Timer {
        id: settleTimer
        interval: 1000
        repeat: false
        onTriggered: {
            service.update();
            if (service.connectedSSID === service.connectingSSID) {
                service.connectingSSID = "";
                service.connectionError = "";
            } else if (service.connectingSSID !== "") {
                service.connectingSSID = "";
            }
        }
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
                const lines = data.split('\n');
                for (const line of lines) {
                    if (line.startsWith('yes:')) {
                        service.connectedSSID = line.substring(4).trim();
                        break;
                    }
                }
            }
        }
    }

    Process {
        id: ethernetProcess
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device"]
        stdout: SplitParser {
            onRead: data => {
                service.isEthernetConnected = false;
                const lines = data.split('\n');
                for (const line of lines) {
                    const parts = line.split(':');
                    if (parts.length >= 3) {
                        const type = parts[1];
                        const state = parts[2];
                        if (type === 'ethernet' && state === 'connected') {
                            service.isEthernetConnected = true;
                            break;
                        }
                    }
                }
            }
        }
    }

    Process {
        id: knownProcess
        command: ["nmcli", "-t", "-f", "NAME", "connection", "show"]
        onStarted: service._knownList = []
        stdout: SplitParser {
            onRead: data => {
                const lines = data.split('\n');
                for (const line of lines) {
                    if (line.trim() !== "")
                        service._knownList.push(line.trim());
                }
            }
        }
        onExited: scanProcess.running = true
    }

    Process {
        id: scanProcess
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY", "dev", "wifi", "list"]
        onStarted: service._scanResults = []

        stdout: SplitParser {
            onRead: data => {
                const lines = data.split('\n');
                for (const line of lines) {
                    if (!line || line.trim() === '')
                        continue;
                    const lastColon = line.lastIndexOf(':');
                    const secondLastColon = line.lastIndexOf(':', lastColon - 1);
                    if (lastColon === -1 || secondLastColon === -1)
                        continue;
                    const ssid = line.substring(0, secondLastColon).replace(/\\:/g, ':');
                    const signal = parseInt(line.substring(secondLastColon + 1, lastColon)) || 0;
                    const security = line.substring(lastColon + 1);

                    if (ssid && ssid !== '--') {
                        const isKnown = service._knownList.includes(ssid);

                        service._scanResults.push({
                            ssid: ssid,
                            signal: signal,
                            secured: security.length > 0 && security !== "",
                            isKnown: isKnown
                        });
                    }
                }
            }
        }
        onExited: {
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
                if (foundIndex !== -1)
                    networks.set(foundIndex, newItem);
                else
                    networks.append(newItem);
            }

            for (let i = networks.count - 1; i >= 0; i--) {
                const oldSSID = networks.get(i).ssid;
                if (!seenSSIDs.has(oldSSID))
                    networks.remove(i);
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
        if (typing)
            return;
        if (connectionProcess.running)
            return;

        statusProcess.running = true;
        connectedProcess.running = true;
        ethernetProcess.running = true;

        if (isEnabled) {
            knownProcess.running = true;
        } else {
            networks.clear();
            service.connectedSSID = "";
        }
    }

    function toggleRadio() {
        var cmd = isEnabled ? "off" : "on";
        Quickshell.execDetached(["nmcli", "radio", "wifi", cmd]);
        delayedUpdate.start();
    }

    function connect(ssid, password) {
        console.log("=== CONNECTING ===");
        
        // Set connecting state
        service.connectingSSID = ssid;
        service.connectionError = "";
        
        var cmd = ["nmcli", "dev", "wifi", "connect", ssid];
        if (password && password !== "")
            cmd.push("password", password);

        connectionProcess.command = cmd;
        connectionProcess.running = true;
    }

    function disconnect() {
        if (service.connectedSSID) {
            Quickshell.execDetached(["nmcli", "connection", "down", service.connectedSSID]);
            delayedUpdate.start();
        }
    }
    
    function clearError(ssid) {
        service.connectionError = "";
    }
}
