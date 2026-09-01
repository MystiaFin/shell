import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../services"

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            Text {
                text: "Notifications"
                color: Theme.statusBarTextColor
                font.family: "Poppins"
                font.pixelSize: 15
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }

            Text {
                visible: NotificationService.count > 0
                text: "Clear all"
                color: clearHover.hovered
                    ? Theme.statusBarRedColor
                    : Theme.statusBarMutedColor
                font.family: "Poppins"
                font.pixelSize: 11

                HoverHandler {
                    id: clearHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler { onTapped: NotificationService.clear() }
            }
        }

        ListView {
            id: list

            Layout.fillWidth: true
            Layout.fillHeight: true
            model: NotificationService.model
            spacing: 20
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            add: Transition {
                NumberAnimation { properties: "opacity,y"; duration: 220; easing.type: Easing.OutCubic }
            }

            displaced: Transition {
                NumberAnimation { properties: "y"; duration: 220; easing.type: Easing.OutCubic }
            }

            delegate: Rectangle {
                id: card

                required property int index
                required property var notification
                required property int notificationId
                required property string appName
                required property string summary
                required property string body
                required property string icon
                required property var receivedAt

                width: list.width
                height: Math.max(76, content.implicitHeight + 24)
                radius: 14
                color: Theme.statusBarSurfaceColor

                Connections {
                    target: card.notification
                    function onClosed(reason) {
                        NotificationService.removeById(card.notificationId);
                    }
                }

                RowLayout {
                    id: content
                    anchors {
                        fill: parent
                        margins: 12
                    }
                    spacing: 10

                    ClippingRectangle {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        Layout.alignment: Qt.AlignTop
                        radius: 10
                        color: Theme.statusBarWorkspaceColor

                        IconImage {
                            anchors.fill: parent
                            anchors.margins: 7
                            source: card.icon
                            visible: card.icon !== ""
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: card.icon === ""
                            text: "󰂚"
                            color: Theme.statusBarBlueColor
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 17
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: card.summary
                            color: Theme.statusBarTextColor
                            font.family: "Poppins"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: card.body !== ""
                            text: card.body
                            textFormat: Text.PlainText
                            color: Theme.statusBarMutedColor
                            font.family: "Poppins"
                            font.pixelSize: 11
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        Text {
                            text: card.appName + "  •  " + Qt.formatTime(card.receivedAt, "hh:mm")
                            color: Theme.launcherSecondaryTextColor
                            font.family: "Poppins"
                            font.pixelSize: 9
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignTop
                        text: "󰅖"
                        color: closeHover.hovered
                            ? Theme.statusBarRedColor
                            : Theme.statusBarMutedColor
                        font.family: "JetBrains Mono Nerd Font"
                        font.pixelSize: 15

                        HoverHandler {
                            id: closeHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler { onTapped: NotificationService.dismiss(card.index) }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: NotificationService.count === 0
                text: "No notifications"
                color: Theme.statusBarMutedColor
                font.family: "Poppins"
                font.pixelSize: 13
            }
        }
    }
}
