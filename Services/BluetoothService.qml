import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: btService

    property bool isPowered: false
    property bool isScanning: false
    
    property ListModel pairedDevices: ListModel {}
    property ListModel newDevices: ListModel {}

    property var _tempPaired: []
    property var _tempAll: []

    Process {
        id: statusProc
        command: ["bluetoothctl", "show"]
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("Powered: yes")) btService.isPowered = true
                else if (data.includes("Powered: no")) btService.isPowered = false
            }
        }
    }

    Process {
        id: scanProc
        command: ["bluetoothctl", "--", "timeout", "5", "scan", "on"]
        onStarted: btService.isScanning = true
        onExited: {
            btService.isScanning = false
            console.log("[BT] Scan finished. Fetching devices...")
            fetchPairedProc.running = true
        }
    }

    Process {
        id: fetchPairedProc
        command: ["bluetoothctl", "paired-devices"]
        onStarted: btService._tempPaired = []
        stdout: SplitParser {
            onRead: data => parseDeviceLine(data, btService._tempPaired, "Paired")
        }
        onExited: fetchAllProc.running = true
    }

    Process {
        id: fetchAllProc
        command: ["bluetoothctl", "devices"]
        onStarted: btService._tempAll = []
        stdout: SplitParser {
            onRead: data => parseDeviceLine(data, btService._tempAll, "All")
        }
        onExited: updateModels()
    }

    Process {
        id: infoProc
        property string targetMac: ""
        property int listIndex: -1
        
        command: ["bluetoothctl", "info", targetMac]
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("Connected: yes")) {
                    if (listIndex >= 0 && listIndex < pairedDevices.count) {
                        pairedDevices.setProperty(listIndex, "connected", true)
                    }
                }
            }
        }
    }

    Process {
        id: actionProc
        stdout: SplitParser { onRead: data => console.log("[BT Action Out]: " + data) }
        stderr: SplitParser { onRead: data => console.log("[BT Action Err]: " + data) }
    }

    function parseDeviceLine(line, targetArray, context) {
        if (!line || line.trim() === "") return;

        var clean = line.replace(/\x1B\[[0-9;]*[a-zA-Z]/g, "").trim();
        
        var parts = clean.split(" ")
        
        if (parts.length >= 2 && parts[0] === "Device") {
            var mac = parts[1]
            var name = parts.slice(2).join(" ") || "Unknown Device"
            
            console.log("[BT Parse " + context + "]: MAC=" + mac + " Name=" + name)
            
            targetArray.push({ mac: mac, name: name, connected: false })
        } else {
        }
    }

    function updateModels() {
        console.log("[BT] Updating Models...")
        
        pairedDevices.clear()
        for (var i = 0; i < _tempPaired.length; i++) {
            pairedDevices.append(_tempPaired[i])
            checkConnection(_tempPaired[i].mac, i)
        }

        newDevices.clear()
        var pairedMacs = _tempPaired.map(d => d.mac)
        
        for (var j = 0; j < _tempAll.length; j++) {
            var dev = _tempAll[j]
            if (!pairedMacs.includes(dev.mac)) {
                newDevices.append(dev)
            }
        }
    }

    function checkConnection(mac, index) {
        infoProc.targetMac = mac
        infoProc.listIndex = index
        infoProc.running = true
    }

    function refresh() {
        if (scanProc.running) return
        console.log("[BT] Refreshing...")
        statusProc.running = true
        if (isPowered) scanProc.running = true
        else {
            pairedDevices.clear()
            newDevices.clear()
        }
    }

    function togglePower() {
        var cmd = isPowered ? "off" : "on"
        actionProc.command = ["bluetoothctl", "power", cmd]
        actionProc.running = true
        delayTimer.callback = refresh
        delayTimer.start()
    }

    function connectDevice(mac) {
        actionProc.command = ["bluetoothctl", "connect", mac]
        actionProc.running = true
        delayTimer.callback = refresh
        delayTimer.start()
    }

    function disconnectDevice(mac) {
        actionProc.command = ["bluetoothctl", "disconnect", mac]
        actionProc.running = true
        delayTimer.callback = refresh
        delayTimer.start()
    }

    function pairAndConnect(mac) {
        // Pair -> Trust -> Connect
        actionProc.command = ["bash", "-c", "bluetoothctl pair " + mac + " && bluetoothctl trust " + mac + " && bluetoothctl connect " + mac]
        actionProc.running = true
        delayTimer.callback = refresh
        delayTimer.start()
    }

    function forgetDevice(mac) {
        actionProc.command = ["bluetoothctl", "remove", mac]
        actionProc.running = true
        delayTimer.callback = refresh
        delayTimer.start()
    }

    Timer {
        id: delayTimer
        interval: 3500
        property var callback: function(){}
        onTriggered: callback()
    }
    
    Timer {
        interval: 20000; running: true; repeat: true
        onTriggered: refresh()
    }

    Component.onCompleted: refresh()
}
