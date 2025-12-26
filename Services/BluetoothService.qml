import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service

    property bool isPowered: false
    property bool isScanning: false
    property string connectedDeviceName: ""
    property string connectedDeviceMac: ""
    property ListModel devices: ListModel {}

    function hasDevice(mac) {
        for (let i = 0; i < devices.count; i++) {
            if (devices.get(i).mac === mac)
                return true;
        }
        return false;
    }

    Process {
        id: statusProcess
        command: ["bluetoothctl", "show"]
        stdout: SplitParser {
            onRead: data => {
                service.isPowered = data.toLowerCase().includes("powered: yes");
                service.isScanning = data.toLowerCase().includes("discovering: yes");
            }
        }
    }

    Process {
        id: connectedProcess
        command: ["bluetoothctl", "info"]
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("Missing device")) {
                    service.connectedDeviceName = "";
                    service.connectedDeviceMac = "";
                    return;
                }

                const lines = data.split('\n');
                let foundName = "";
                let foundMac = "";
                let isConnected = false;

                for (const line of lines) {
                    const trim = line.trim();
                    if (trim.startsWith("Device"))
                        foundMac = trim.split(" ")[1];
                    if (trim.startsWith("Name:"))
                        foundName = trim.substring(5).trim();
                    if (trim.startsWith("Connected: yes"))
                        isConnected = true;
                }

                if (isConnected) {
                    service.connectedDeviceName = foundName;
                    service.connectedDeviceMac = foundMac;
                } else {
                    service.connectedDeviceName = "";
                    service.connectedDeviceMac = "";
                }
            }
        }
    }

    Process {
        id: listProcess
        command: ["bluetoothctl", "devices"]

        stdout: SplitParser {
            onRead: data => {
                const lines = data.split('\n');
                for (const line of lines) {
                    if (!line || line.trim() === '')
                        continue;

                    const parts = line.split(" ");
                    if (parts[0] !== "Device")
                        continue;
                    const mac = parts[1];
                    const name = parts.slice(2).join(" ");

                    if (mac && !service.hasDevice(mac)) {
                        service.devices.append({
                            mac: mac,
                            name: name,
                            connected: mac === service.connectedDeviceMac
                        });
                    }
                }
            }
        }
    }

    Process {
        id: discoveryProcess
        command: ["timeout", "10", "bluetoothctl", "scan", "on"]

        onExited: service.update()
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: service.update()
    }

    function update() {
        statusProcess.running = true;
        connectedProcess.running = true;

        if (isPowered) {
            devices.clear();
            listProcess.running = true;
        } else {
            devices.clear();
        }
    }

    function togglePower() {
        const cmd = isPowered ? "off" : "on";
        Quickshell.execDetached(["sh", "-c", "bluetoothctl power " + cmd]);

        service.isPowered = !service.isPowered;
    }

    function startDiscovery() {
        if (isPowered) {
            discoveryProcess.running = true;
            service.isScanning = true;
        }
    }

    function connect(mac) {
        Quickshell.execDetached(["pkill", "-f", "bluetoothctl scan on"]);

        Quickshell.execDetached(["sh", "-c", "bluetoothctl connect " + mac]);
    }

    function disconnect() {
        if (service.connectedDeviceMac) {
            Quickshell.execDetached(["sh", "-c", "bluetoothctl disconnect " + service.connectedDeviceMac]);
        }
    }
}
