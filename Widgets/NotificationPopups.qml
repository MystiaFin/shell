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
                    height: 78
                    color: "#1e1e2e"
                    radius: 16
                    border.width: 2
                    border.color: "#89b4fa"

                    property int myIndex: index

                    transform: Translate {
                        id: slideTransform
                        x: 400
                    }

                    Component.onCompleted: {
                        slideInAnim.start();
                        hideTimer.start();
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
                        spacing: 12

                        Image {
                            width: 48
                            height: 48
                            source: model.icon
                            fillMode: Image.PreserveAspectFit
                        }

                        Column {
                            width: parent.width - 72
                            spacing: 4

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
                }
            }
        }
    }
}
