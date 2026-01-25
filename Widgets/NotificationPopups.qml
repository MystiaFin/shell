import Quickshell
import QtQuick
import "../Services" as Services

Scope {
    Services.NotificationService {
        id: notificationService
    }

    PanelWindow {
        anchors {
            top: true
            right: true
        }
        margins {
            top: 4
            right: 4
        }
        width: notificationService.notificationModel.count > 0 ? 360 : 0
        height: notificationService.notificationModel.count > 0 ? notifColumn.height : 0
        color: "transparent"

        Column {
            id: notifColumn
            spacing: 10

            move: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }

            add: Transition {
                NumberAnimation {
                    properties: "y"
                    from: -100
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }

            Repeater {
                model: notificationService.notificationModel

                Rectangle {
                    width: 355
                    height: 88
                    color: "#1e1e2e"
                    radius: 16
                    border.width: 2
                    border.color: "#89b4fa"
                    clip: true

                    property int myIndex: index

                    transform: Translate {
                        id: slideTransform
                        x: 400
                    }

                    Component.onCompleted: {
                        slideInAnim.start();
                        hideTimer.start();
                        progressAnim.start();
                    }

                    NumberAnimation {
                        id: slideInAnim
                        target: slideTransform
                        property: "x"
                        from: 400
                        to: 0
                        duration: 700
                        easing.type: Easing.OutCubic
                    }

                    SequentialAnimation {
                        id: slideOutAnim
                        NumberAnimation {
                            target: slideTransform
                            property: "x"
                            to: 400
                            duration: 700
                            easing.type: Easing.InCubic
                        }
                        ScriptAction {
                            script: notificationService.remove(myIndex)
                        }
                    }

                    Timer {
                        id: hideTimer
                        interval: 5000
                        onTriggered: slideOutAnim.start()
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 12
                        anchors.rightMargin: 40
                        anchors.bottomMargin: 18
                        spacing: 12

                        Image {
                            width: 48
                            height: 48
                            source: model.icon
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - 60
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: model.summary
                                color: "#cdd6f4"
                                font.pixelSize: 16
                                font.bold: true
                                width: parent.width
                                elide: Text.ElideRight
                            }

                            Text {
                                text: model.body
                                color: "#a6adc8"
                                font.pixelSize: 14
                                width: parent.width
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // Close button
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        width: 28
                        height: 28
                        radius: 14
                        color: closeMouseArea.containsMouse ? "#f38ba8" : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: closeMouseArea.containsMouse ? "#1e1e2e" : "#a6adc8"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }

                        MouseArea {
                            id: closeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                hideTimer.stop();
                                progressAnim.stop();
                                slideOutAnim.start();
                            }
                        }
                    }

                    // Progress bar
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        anchors.bottomMargin: 6
                        height: 2
                        radius: 1.5
                        color: "#313244"

                        Rectangle {
                            id: progressBar
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width
                            radius: 1.5
                            color: "#89b4fa"

                            NumberAnimation {
                                id: progressAnim
                                target: progressBar
                                property: "width"
                                from: progressBar.parent.width
                                to: 0
                                duration: hideTimer.interval
                                easing.type: Easing.Linear
                            }
                        }
                    }
                }
            }
        }
    }
}
