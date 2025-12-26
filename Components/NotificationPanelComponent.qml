import QtQuick
import QtQuick.Layouts

Rectangle {
    id: notificationPanel
    
    property var notificationModel
    
    color: "transparent"
    
    Flickable {
        anchors.fill: parent
        anchors.margins: 12
        clip: true
        contentWidth: width
        contentHeight: notifColumn.height
        boundsBehavior: Flickable.StopAtBounds
        
        Column {
            id: notifColumn
            width: parent.width
            spacing: 12
            
            // Animation when items are removed
            move: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }
            
            Repeater {
                model: notificationPanel.notificationModel
                
                delegate: Rectangle {
                    id: notifCard
                    width: parent.width
                    height: 90
                    color: "#1e1e2e"
                    radius: 12
                    
                    property int myIndex: index
                    
                    // Fade out animation
                    SequentialAnimation {
                        id: fadeOutAnim
                        
                        NumberAnimation {
                            target: notifCard
                            property: "opacity"
                            to: 0
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                        
                        NumberAnimation {
                            target: notifCard
                            property: "height"
                            to: 0
                            duration: 100
                            easing.type: Easing.InOutQuad
                        }
                        
                        ScriptAction {
                            script: notificationPanel.notificationModel.remove(notifCard.myIndex)
                        }
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12
                        
                        // Icon Container
                        Rectangle {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            color: "transparent"
                            
                            Image {
                                anchors.fill: parent
                                source: model.icon
                                fillMode: Image.PreserveAspectFit
                                sourceSize.width: 48
                                sourceSize.height: 48
                                onStatusChanged: {
                                    if (status === Image.Error)
                                        visible = false
                                }
                            }
                        }
                        
                        // Text Column
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4
                            
                            Text {
                                text: model.summary
                                color: "#cdd6f4"
                                font.pixelSize: 16
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            
                            Text {
                                text: model.body
                                color: "#a6adc8"
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                elide: Text.ElideRight
                                maximumLineCount: 2
                            }
                        }
                        
                        // Close Button
                        Rectangle {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            Layout.alignment: Qt.AlignTop
                            color: closeMouseArea.containsMouse ? "#f38ba8" : "#313244"
                            radius: 14
                            
                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: "#cdd6f4"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            MouseArea {
                                id: closeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    fadeOutAnim.start()
                                }
                            }
                        }
                    }
                }
            }
            
            // Empty state when no notifications
            Item {
                width: parent.width
                height: 100
                visible: notificationPanel.notificationModel.count === 0
                
                Text {
                    anchors.centerIn: parent
                    text: "No notifications"
                    color: "#6c7086"
                    font.pixelSize: 16
                }
            }
        }
    }
}
