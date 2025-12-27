import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Services" as Service

Rectangle {
    id: btRoot
    width: 320
    height: 450
    color: "transparent"

    Service.BluetoothService { id: btService }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // --- Header ---
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
                        text: btService.isPowered ? "Bluetooth On" : "Bluetooth Off"
                        color: "#cdd6f4"
                        font.bold: true
                    }
                    Text {
                        text: btService.isScanning ? "Scanning..." : "Idle"
                        color: "#a6adc8"
                        font.pixelSize: 10
                        visible: btService.isPowered
                    }
                }

                // Toggle Switch
                Rectangle {
                    width: 40; height: 20; radius: 10
                    color: btService.isPowered ? "#89b4fa" : "#313244"
                    Rectangle {
                        width: 16; height: 16; radius: 8; color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                        x: btService.isPowered ? 22 : 2
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: btService.togglePower()
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        // --- Content Area ---
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
                            onClicked: (mouse) => {
                                if (mouse.button === Qt.RightButton) {
                                    // Right click to Forget
                                    btService.forgetDevice(model.mac)
                                } else {
                                    // Left click to Toggle Connection
                                    if (model.connected) btService.disconnectDevice(model.mac)
                                    else btService.connectDevice(model.mac)
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
                
                Item {
                    visible: btService.isScanning
                    Layout.fillWidth: true
                    height: 30
                    Text {
                        anchors.centerIn: parent
                        text: "Scanning for devices..."
                        color: "#585b70"
                        font.italic: true
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
