import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    
    property var wifiService
    
    color: "transparent"
    
    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: content.height
        clip: true
        
        Column {
            id: content
            width: parent.width
            spacing: 16
            padding: 16
            
            Rectangle {
                width: parent.width - 32
                height: 80
                radius: 12
                color: "#1e1e2e"
                border.width: 2
                border.color: wifiService.isEnabled ? "#89b4fa" : "#313244"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: 24
                        color: wifiService.isEnabled ? "#89b4fa" : "#313244"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰖩"
                            font.pixelSize: 28
                            color: "#1e1e2e"
                        }
                    }
                    
                    Column {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: wifiService.isEnabled ? "WiFi" : "WiFi Off"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#cdd6f4"
                        }
                        
                        Text {
                            text: wifiService.connectedSSID || "Not connected"
                            font.pixelSize: 14
                            color: "#a6adc8"
                            visible: wifiService.isEnabled
                        }
                    }
                    
                    Rectangle {
                        Layout.preferredWidth: 56
                        Layout.preferredHeight: 32
                        radius: 16
                        color: wifiService.isEnabled ? "#89b4fa" : "#313244"
                        
                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            color: "#ffffff"
                            anchors.verticalCenter: parent.verticalCenter
                            x: wifiService.isEnabled ? parent.width - width - 3 : 3
                            
                            Behavior on x {
                                NumberAnimation { duration: 200 }
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: wifiService.toggleRadio()
                        }
                    }
                }
            }
            
            Rectangle {
                width: parent.width - 32
                height: 50
                radius: 12
                color: "#f38ba8"
                visible: wifiService.connectedSSID !== ""
                
                Text {
                    anchors.centerIn: parent
                    text: "Disconnect from " + wifiService.connectedSSID
                    font.pixelSize: 14
                    font.bold: true
                    color: "#1e1e2e"
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: wifiService.disconnect()
                }
            }
            
            Column {
                width: parent.width - 32
                spacing: 12
                visible: wifiService.isEnabled
                
                Text {
                    text: "Available Networks"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#cdd6f4"
                }
                
                Repeater {
                    model: wifiService.networks
                    
                    Rectangle {
                        width: parent.width
                        height: 70
                        radius: 12
                        color: "#1e1e2e"
                        border.width: model.ssid === wifiService.connectedSSID ? 2 : 1
                        border.color: model.ssid === wifiService.connectedSSID ? "#89b4fa" : "#313244"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12
                            
                            Text {
                                text: model.signal > 75 ? "󰤨" : 
                                      model.signal > 50 ? "󰤥" :
                                      model.signal > 25 ? "󰤢" : "󰤟"
                                font.pixelSize: 24
                                color: "#89b4fa"
                            }
                            
                            Column {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                Text {
                                    text: model.ssid
                                    font.pixelSize: 16
                                    font.bold: model.ssid === wifiService.connectedSSID
                                    color: "#cdd6f4"
                                }
                                
                                Row {
                                    spacing: 8
                                    
                                    Text {
                                        text: model.secured ? "🔒 Secured" : "🔓 Open"
                                        font.pixelSize: 12
                                        color: "#a6adc8"
                                    }
                                    
                                    Text {
                                        text: model.signal + "%"
                                        font.pixelSize: 12
                                        color: "#a6adc8"
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 80
                                height: 36
                                radius: 10
                                color: model.ssid === wifiService.connectedSSID ? "#a6e3a1" : "#89b4fa"
                                visible: model.ssid === wifiService.connectedSSID || !wifiService.connectedSSID
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: model.ssid === wifiService.connectedSSID ? "Connected" : "Connect"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#1e1e2e"
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    enabled: model.ssid !== wifiService.connectedSSID
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: wifiService.connect(model.ssid)
                                }
                            }
                        }
                    }
                }
                
                Rectangle {
                    width: parent.width
                    height: 100
                    radius: 12
                    color: "#1e1e2e"
                    visible: wifiService.networks.count === 0
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Scanning for networks..."
                        font.pixelSize: 14
                        color: "#6c7086"
                    }
                }
            }
        }
    }
}
