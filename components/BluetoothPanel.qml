import Quickshell
import QtQuick
import QtQuick.Layouts
import "../services"

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            radius: 14
            color: Theme.statusBarSurfaceColor

            RowLayout {
                anchors {
                    fill: parent
                    margins: 10
                }
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 12
                    color: BluetoothService.enabled
                        ? Theme.statusBarAccentColor
                        : Theme.statusBarSurfaceBorderColor

                    Text {
                        anchors.centerIn: parent
                        text: "󰂯"
                        color: Theme.statusBarBackgroundColor
                        font.family: "JetBrains Mono Nerd Font"
                        font.pixelSize: 18
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        text: BluetoothService.enabled ? "Bluetooth" : "Bluetooth off"
                        color: Theme.statusBarTextColor
                        font.family: "Poppins"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: !BluetoothService.available ? "No adapter"
                            : BluetoothService.scanning ? "Scanning for devices…" : "Ready"
                        color: Theme.statusBarMutedColor
                        font.family: "Poppins"
                        font.pixelSize: 10
                    }
                }

                UtilitySwitch {
                    enabled: BluetoothService.available
                    checked: BluetoothService.enabled
                    onToggled: BluetoothService.togglePower()
                }
            }
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

            delegate: Rectangle {
                id: deviceCard

                required property var modelData

                width: deviceList.width
                height: 54
                radius: 12
                color: modelData.connected
                    ? Theme.statusBarWorkspaceColor
                    : Theme.statusBarSurfaceColor

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 9
                    }
                    spacing: 9

                    Rectangle {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        radius: 10
                        color: Theme.statusBarWorkspaceColor

                        Image {
                            anchors.fill: parent
                            anchors.margins: 7
                            source: deviceCard.modelData.icon
                                ? Quickshell.iconPath(deviceCard.modelData.icon) : ""
                            visible: source !== ""
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !parent.children[0].visible
                            text: "󰂯"
                            color: Theme.statusBarAccentColor
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 16
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            text: deviceCard.modelData.name || deviceCard.modelData.deviceName || "Unknown device"
                            color: Theme.statusBarTextColor
                            font.family: "Poppins"
                            font.pixelSize: 12
                            font.weight: deviceCard.modelData.connected ? Font.DemiBold : Font.Normal
                            elide: Text.ElideRight
                        }

                        Text {
                            text: deviceCard.modelData.connected ? "Connected"
                                : deviceCard.modelData.pairing ? "Pairing…"
                                : deviceCard.modelData.paired ? "Paired" : "Available"
                            color: deviceCard.modelData.connected
                                ? Theme.statusBarGreenColor
                                : Theme.statusBarMutedColor
                            font.family: "Poppins"
                            font.pixelSize: 9
                        }
                    }

                    Text {
                        visible: deviceCard.modelData.batteryAvailable
                        text: Math.round(deviceCard.modelData.battery * 100) + "%"
                        color: Theme.statusBarMutedColor
                        font.family: "Poppins"
                        font.pixelSize: 9
                    }

                    Text {
                        visible: deviceCard.modelData.paired
                        text: "󰅖"
                        color: forgetHover.hovered
                            ? Theme.statusBarRedColor
                            : Theme.statusBarMutedColor
                        font.family: "JetBrains Mono Nerd Font"
                        font.pixelSize: 13

                        HoverHandler {
                            id: forgetHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler {
                            gesturePolicy: TapHandler.ReleaseWithinBounds
                            onTapped: BluetoothService.forgetDevice(deviceCard.modelData)
                        }
                    }
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        if (deviceCard.modelData.paired)
                            BluetoothService.connectDevice(deviceCard.modelData);
                        else
                            BluetoothService.pairDevice(deviceCard.modelData);
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: deviceList.combinedDevices.length === 0
                text: BluetoothService.scanning ? "Scanning…" : "No devices found"
                color: Theme.statusBarMutedColor
                font.family: "Poppins"
                font.pixelSize: 12
            }
        }
    }
}
