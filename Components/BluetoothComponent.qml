import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../Services" as Service
import ".." as Theme

Rectangle {
    id: root
    width: 320
    height: 450
    color: "transparent"

    Service.BluetoothService {
        id: btService
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: content.height
        clip: true

        Column {
            id: content
            width: parent.width
            spacing: 12
            padding: 12

            Rectangle {
                width: parent.width - 24
                height: 60
                radius: 12
                color: Theme.Colors.base
                border.width: 1
                border.color: btService.isPowered ? Theme.Colors.blue : Theme.Colors.surface0

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 18
                        color: btService.isPowered ? Theme.Colors.blue : Theme.Colors.surface0

                        Text {
                            anchors.centerIn: parent
                            text: "󰂯"
                            font.pixelSize: 20
                            font.family: "Jetbrains Mono Nerd Font"
                            color: Theme.Colors.base
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: btService.isPowered ? "Bluetooth" : "Bluetooth Off"
                            font.pixelSize: 14
                            font.family: "Poppins"
                            color: Theme.Colors.text
                        }

                        Text {
                            text: btService.isPowered ? (btService.isScanning ? "Scanning for devices" : "Powered") : "Power Off"
                            font.pixelSize: 12
                            font.family: "Poppins"
                            color: btService.isPowered ? Theme.Colors.blue : Theme.Colors.subtext0
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 24
                        radius: 12
                        color: btService.isPowered ? Theme.Colors.blue : Theme.Colors.surface0

                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: Theme.Colors.white
                            anchors.verticalCenter: parent.verticalCenter
                            x: btService.isPowered ? parent.width - width - 2 : 2

                            Behavior on x {
                                NumberAnimation {
                                    duration: 200
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btService.togglePower()
                        }
                    }
                }
            }

            Column {
                width: parent.width - 24
                spacing: 8
                visible: btService.isPowered && btService.pairedDevices.count > 0

                Text {
                    text: "My Devices"
                    font.pixelSize: 13
                    font.family: "Poppins"
                    color: Theme.Colors.text
                }

                Repeater {
                    model: btService.pairedDevices

                    Rectangle {
                        id: pairedCard
                        width: parent.width
                        height: 50
                        radius: 10
                        color: Theme.Colors.base
                        border.width: 1
                        border.color: model.connected ? Theme.Colors.green : Theme.Colors.surface0

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                radius: 8
                                color: Theme.Colors.surface0

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    source: model.icon !== "" ? Quickshell.iconPath(model.icon) : ""
                                    visible: model.icon !== ""
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰂯"
                                    font.pixelSize: 16
                                    font.family: "Jetbrains Mono Nerd Font"
                                    color: Theme.Colors.blue
                                    visible: model.icon === ""
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: model.name
                                    font.pixelSize: 13
                                    font.family: "Poppins"
                                    color: model.connected ? Theme.Colors.blue : Theme.Colors.text
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Text {
                                    text: model.connected ? "Connected" : "Paired"
                                    font.pixelSize: 10
                                    font.family: "Poppins"
                                    color: model.connected ? Theme.Colors.green : Theme.Colors.subtext0
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                radius: 8
                                color: model.connected ? Theme.Colors.red : Theme.Colors.green

                                Text {
                                    anchors.centerIn: parent
                                    text: model.connected ? "󰅖" : "󰂱"
                                    font.pixelSize: 15
                                    font.family: "Jetbrains Mono Nerd Font"
                                    color: Theme.Colors.base
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (model.connected)
                                            btService.disconnectDevice(model.mac);
                                        else
                                            btService.connectDevice(model.mac);
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btService.forgetDevice(model.mac)
                        }
                    }
                }
            }

            Column {
                width: parent.width - 24
                spacing: 8
                visible: btService.isPowered && btService.newDevices.count > 0

                Text {
                    text: "Available Devices"
                    font.pixelSize: 13
                    font.family: "Poppins"
                    color: Theme.Colors.text
                }

                Repeater {
                    model: btService.newDevices

                    Rectangle {
                        id: newCard
                        width: parent.width
                        height: 45
                        radius: 10
                        color: Theme.Colors.base

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                radius: 8
                                color: Theme.Colors.surface0

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    source: model.icon !== "" ? Quickshell.iconPath(model.icon) : ""
                                    visible: model.icon !== ""
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰂯"
                                    font.pixelSize: 14
                                    font.family: "Jetbrains Mono Nerd Font"
                                    color: Theme.Colors.blue
                                    visible: model.icon === ""
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: model.name
                                font.pixelSize: 13
                                font.family: "Poppins"
                                color: Theme.Colors.text
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 28
                                radius: 8
                                color: Theme.Colors.blue

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰂱"
                                    font.pixelSize: 14
                                    font.family: "Jetbrains Mono Nerd Font"
                                    color: Theme.Colors.base
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: btService.pairAndConnect(model.mac)
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btService.pairAndConnect(model.mac)
                        }
                    }
                }
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Scanning..."
                font.pixelSize: 12
                font.family: "Poppins"
                color: Theme.Colors.overlay0
                visible: btService.isPowered && btService.isScanning && btService.newDevices.count === 0 && btService.pairedDevices.count === 0
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "No devices found"
                font.pixelSize: 12
                font.family: "Poppins"
                color: Theme.Colors.surface1
                font.italic: true
                visible: btService.isPowered && !btService.isScanning && btService.newDevices.count === 0
            }
        }
    }
}