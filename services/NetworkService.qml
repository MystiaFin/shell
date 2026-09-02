pragma Singleton

import Quickshell
import Quickshell.Networking
import QtQuick

Singleton {
    id: root

    readonly property var wifiDevice: {
        const devices = Networking.devices.values;
        return devices.find(device => device.type === DeviceType.Wifi) || null;
    }
    readonly property var networks: wifiDevice ? wifiDevice.networks.values : []
    readonly property var connectedNetwork: networks.find(network => network.connected) || null
    readonly property bool enabled: Networking.wifiEnabled
    readonly property bool hardwareEnabled: Networking.wifiHardwareEnabled
    readonly property bool scanning: wifiDevice ? wifiDevice.scannerEnabled : false
    property bool scanningRequested: false

    function toggleWifi(): void {
        if (hardwareEnabled) {
            Networking.wifiEnabled = !Networking.wifiEnabled;
            Qt.callLater(root.updateScanner);
        }
    }

    function disconnect(): void {
        if (connectedNetwork)
            connectedNetwork.disconnect();
    }

    onWifiDeviceChanged: updateScanner()
    onScanningRequestedChanged: updateScanner()

    function updateScanner(): void {
        if (wifiDevice) {
            if (scanningRequested) {
                scannerStopTimer.stop();
                wifiDevice.scannerEnabled = true;
            } else if (wifiDevice.scannerEnabled) {
                scannerStopTimer.restart();
            } else {
                scannerStopTimer.stop();
                wifiDevice.scannerEnabled = false;
            }
        }
    }

    Timer {
        id: scannerStopTimer
        interval: 500
        onTriggered: {
            if (root.wifiDevice && !root.scanningRequested)
                root.wifiDevice.scannerEnabled = false;
        }
    }
}
