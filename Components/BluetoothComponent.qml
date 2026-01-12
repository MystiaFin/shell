import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Services" as Service

Rectangle {
    id: btRoot
    width: 320
    height: 450
    color: "transparent"

    Service.BluetoothService {
        id: btService
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Rectangle {
            Layout.fillWidth: true
            height: 50
            color: "#1e1e2e"
            radius: 12
            border.color: btService.isPowered ? "#89b4fa" : "#313244"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    text: "󰂯"
                    font.pixelSize: 22
                    color: btService.isPowered ? "#89b4fa" : "#585b70"
                }

                Column {
                    Layout.fillWidth: true
                    Text {
                        text: btService.isScanning ? "Scanning On" : "Scanning Off"
                        color: "#cdd6f4"
                        font.bold: true
                    }
                    Text {
                        text: btService.isPowered ? "Bluetooth Powered" : "Power Off"
                        color: "#a6adc8"
                        font.pixelSize: 10
                    }
                }

                Rectangle {
                    width: 40
                    height: 20
                    radius: 10
                    color: !btService.isPowered ? "#313244" : (btService.isScanning ? "#89b4fa" : "#45475a")

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: !btService.isPowered ? "#585b70" : "white"
                        anchors.verticalCenter: parent.verticalCenter
                        x: btService.isScanning ? 22 : 2
                        Behavior on x {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: btService.isPowered
                        cursorShape: btService.isPowered ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                        onClicked: btService.toggleScan()
                    }
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: btService.isPowered
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 15

                Text {
                    text: "My Devices"
                    color: "#a6adc8"
                    font.pixelSize: 12
                    font.bold: true
                    visible: btService.pairedDevices.count > 0
                }

                Repeater {
                    model: btService.pairedDevices
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 50
                        color: model.connected ? "#313244" : "#1e1e2e"
                        radius: 8
                        border.width: 1
                        border.color: model.connected ? "#a6e3a1" : "#313244"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10

                            Column {
                                Layout.fillWidth: true
                                Text {
                                    text: model.name
                                    color: "#cdd6f4"
                                    font.bold: true
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                                Text {
                                    text: model.connected ? "Connected" : "Paired"
                                    color: model.connected ? "#a6e3a1" : "#6c7086"
                                    font.pixelSize: 10
                                }
                            }

                            Text {
                                text: model.connected ? "󰅖" : "󰂱"
                                color: model.connected ? "#f38ba8" : "#89b4fa"
                                font.pixelSize: 18
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton) {
                                    btService.forgetDevice(model.mac);
                                } else {
                                    if (model.connected)
                                        btService.disconnectDevice(model.mac);
                                    else
                                        btService.connectDevice(model.mac);
                                }
                            }
                        }
                    }
                }

                Text {
                    text: "Available Devices"
                    color: "#a6adc8"
                    font.pixelSize: 12
                    font.bold: true
                    visible: btService.newDevices.count > 0
                }

                Repeater {
                    model: btService.newDevices
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 45
                        color: "#181825"
                        radius: 8

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            Text {
                                text: model.name
                                color: "#a6adc8"
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            Text {
                                text: "Pair"
                                color: "#89b4fa"
                                font.pixelSize: 11
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btService.pairAndConnect(model.mac)
                        }
                    }
                }

                Text {
                    visible: btService.newDevices.count === 0 && !btService.isScanning
                    text: "Turn on scanning to find devices"
                    color: "#45475a"
                    font.italic: true
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
