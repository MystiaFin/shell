import QtQuick
import Quickshell
import Quickshell.Bluetooth

Item {
    id: btService

    readonly property bool isPowered: Bluetooth.defaultAdapter !== null ? Bluetooth.defaultAdapter.enabled : false
    readonly property bool isScanning: Bluetooth.defaultAdapter !== null ? Bluetooth.defaultAdapter.discovering : false

    property ListModel pairedDevices: ListModel {}
    property ListModel newDevices: ListModel {}

    Connections {
        target: Bluetooth
        function onDevicesChanged() {
            btService.updateLists()
        }
        function onDefaultAdapterChanged() {
            btService.updateLists()
        }
    }

    function findDevice(mac) {
        var list = Bluetooth.devices.values;
        for (var i = 0; i < list.length; i++) {
            var dev = list[i];
            if (dev.address === mac) return dev;
        }
        return null;
    }

    function updateLists() {
        pairedDevices.clear();
        newDevices.clear();

        var list = Bluetooth.devices.values;
        for (var i = 0; i < list.length; i++) {
            var dev = list[i];
            var name = dev.name !== "" ? dev.name : "Unknown Device";
            if (dev.paired) {
                pairedDevices.append({ mac: dev.address, name: name, connected: dev.connected, icon: dev.icon });
            } else {
                newDevices.append({ mac: dev.address, name: name, icon: dev.icon });
            }
        }
    }

    function refresh() {
        updateLists();
    }

    function toggleScan() {
        var adapter = Bluetooth.defaultAdapter;
        if (adapter !== null) adapter.discovering = !adapter.discovering;
    }

    function togglePower() {
        var adapter = Bluetooth.defaultAdapter;
        if (adapter === null) return;
        var enable = !adapter.enabled;
        adapter.enabled = enable;
        if (!enable) {
            pairedDevices.clear();
            newDevices.clear();
        }
    }

    function connectDevice(mac) {
        var dev = findDevice(mac);
        if (dev !== null) dev.connect();
        delayTimer.restart();
    }

    function disconnectDevice(mac) {
        var dev = findDevice(mac);
        if (dev !== null) dev.disconnect();
        delayTimer.restart();
    }

    function pairAndConnect(mac) {
        var dev = findDevice(mac);
        if (dev !== null) {
            dev.pair();
            dev.trusted = true;
            dev.connect();
        }
        delayTimer.restart();
    }

    function forgetDevice(mac) {
        var dev = findDevice(mac);
        if (dev !== null) dev.forget();
        delayTimer.restart();
    }

    Timer {
        id: delayTimer
        interval: 1200
        onTriggered: btService.updateLists()
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            btService.updateLists();
            var adapter = Bluetooth.defaultAdapter;
            if (adapter !== null && adapter.enabled && !adapter.discovering) {
                adapter.discovering = true;
            }
        }
    }

    Component.onCompleted: updateLists()
}