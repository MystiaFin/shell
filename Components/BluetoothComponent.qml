import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var btService
    color: "transparent"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: btService.isPowered ? "#89b4fa" : "#313244"
                radius: 8

                Text {
                    anchors.centerIn: parent
                    text: btService.isPowered ? "Bluetooth ON" : "Bluetooth OFF"
                    color: "#1e1e2e"
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: btService.toggle()
                }
            }

            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                color: btService.isScanning ? "#fab387" : "#313244"
                radius: 8
                visible: btService.isPowered

                Text {
                    anchors.centerIn: parent
                    text: "󰑐"
                    rotation: btService.isScanning ? 180 : 0
                    Behavior on rotation {
                        NumberAnimation {
                            duration: 500
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: btService.toggleScan()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "#f38ba8"
            radius: 8
            visible: btService.connectedDeviceMac !== ""

            Text {
                anchors.centerIn: parent
                text: "Disconnect Device"
                color: "#1e1e2e"
                font.bold: true
            }
            MouseArea {
                anchors.fill: parent
                onClicked: btService.disconnect()
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: btService.devices
            spacing: 5

            delegate: Rectangle {
                width: ListView.view.width
                height: 50
                color: "#1e1e2e"
                radius: 8
                border.width: model.mac === btService.connectedDeviceMac ? 2 : 0
                border.color: "#a6e3a1"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    Column {
                        Layout.fillWidth: true
                        Text {
                            text: model.name
                            color: "#cdd6f4"
                            font.bold: true
                        }
                        Text {
                            text: model.mac
                            color: "#6c7086"
                            font.pixelSize: 10
                        }
                    }

                    Rectangle {
                        width: 60
                        height: 30
                        radius: 5
                        color: "#89b4fa"
                        visible: model.mac !== btService.connectedDeviceMac

                        Text {
                            anchors.centerIn: parent
                            text: "Pair"
                            color: "#1e1e2e"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: btService.connectDevice(model.mac)
                        }
                    }

                    Text {
                        text: "Connected"
                        color: "#a6e3a1"
                        visible: model.mac === btService.connectedDeviceMac
                    }
                }
            }
        }
    }
}
