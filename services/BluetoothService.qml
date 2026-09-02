pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property bool scanning: available && adapter.discovering
    readonly property var devices: Bluetooth.devices.values
    readonly property var pairedDevices: devices.filter(device => device.paired)
    readonly property var availableDevices: devices.filter(device => !device.paired)
    property var pendingPairDevice: null
    property bool scanningRequested: false

    function togglePower(): void {
        if (adapter) {
            adapter.enabled = !adapter.enabled;
            Qt.callLater(root.updateScanner);
        }
    }

    function updateScanner(): void {
        if (adapter) {
            adapter.discovering = adapter.enabled
                && scanningRequested;
        }
    }

    function connectDevice(device: var): void {
        if (device.connected)
            device.disconnect();
        else
            device.connect();
    }

    function pairDevice(device: var): void {
        pendingPairDevice = device;
        device.pair();
    }

    function forgetDevice(device: var): void {
        device.forget();
    }

    onScanningRequestedChanged: updateScanner()

    Connections {
        target: Bluetooth
        function onDefaultAdapterChanged() { root.updateScanner(); }
    }

    Connections {
        target: root.pendingPairDevice
        ignoreUnknownSignals: true

        function onPairedChanged() {
            if (root.pendingPairDevice && root.pendingPairDevice.paired) {
                root.pendingPairDevice.trusted = true;
                root.pendingPairDevice.connect();
                root.pendingPairDevice = null;
            }
        }
    }
}
