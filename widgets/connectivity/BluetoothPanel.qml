import QtQuick
import QtQuick.Layouts
import "../../components/theme"
import "../../services"

Item {
    id: root

    readonly property string statusText: {
        if (!BluetoothService.available)
            return "No adapter";
        return BluetoothService.scanning ? "Scanning for devices…" : "Ready";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        ConnectivityHeader {
            icon: Icons.bluetooth
            title: BluetoothService.enabled ? "Bluetooth" : "Bluetooth off"
            statusText: root.statusText
            active: BluetoothService.enabled
            toggleEnabled: BluetoothService.available
            onToggleRequested: BluetoothService.togglePower()
        }

        ListView {
            id: deviceList

            property var combinedDevices: BluetoothService.pairedDevices
                .concat(BluetoothService.availableDevices)

            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: BluetoothService.enabled
            model: combinedDevices
            spacing: 7
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: BluetoothDeviceCard {
                width: deviceList.width
                onActivationRequested: device => {
                    if (device.paired)
                        BluetoothService.connectDevice(device);
                    else
                        BluetoothService.pairDevice(device);
                }
                onForgetRequested: device => BluetoothService.forgetDevice(device)
            }

            Text {
                anchors.centerIn: parent
                visible: deviceList.combinedDevices.length === 0
                text: BluetoothService.scanning ? "Scanning…" : "No devices found"
                color: Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 12
            }
        }
    }
}
