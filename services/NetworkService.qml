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

    Connections {
        target: UtilityCenterState

        function onVisibleChanged() { root.updateScanner(); }
        function onPageChanged() { root.updateScanner(); }
    }

    onWifiDeviceChanged: updateScanner()

    function updateScanner(): void {
        if (wifiDevice) {
            const shouldScan = UtilityCenterState.visible
                && UtilityCenterState.page === "wifi";

            if (shouldScan) {
                scannerStopTimer.stop();
                wifiDevice.scannerEnabled = true;
            } else if (!UtilityCenterState.visible && wifiDevice.scannerEnabled) {
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
            if (root.wifiDevice && !UtilityCenterState.visible)
                root.wifiDevice.scannerEnabled = false;
        }
    }
}
