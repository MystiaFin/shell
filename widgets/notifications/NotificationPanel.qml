import QtQuick
import QtQuick.Layouts
import "../../components/theme"
import "../../services"

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
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 15
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }

            Text {
                visible: NotificationService.notificationCount > 0
                text: "Clear all"
                color: clearHover.hovered
                    ? Theme.dangerColor
                    : Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
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
            model: NotificationService.notificationModel
            spacing: 20
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            add: Transition {
                NumberAnimation { properties: "opacity,y"; duration: 220; easing.type: Easing.OutCubic }
            }

            displaced: Transition {
                NumberAnimation { properties: "y"; duration: 220; easing.type: Easing.OutCubic }
            }

            delegate: Item {
                id: delegateRoot

                required property var notification
                required property int notificationId
                required property string appName
                required property string summary
                required property string body
                required property string icon
                required property var receivedAt

                width: list.width
                height: card.implicitHeight

                Connections {
                    target: delegateRoot.notification
                    function onClosed(reason) {
                        NotificationService.removeById(delegateRoot.notificationId);
                    }
                }

                NotificationCard {
                    id: card
                    anchors.fill: parent
                    notificationId: delegateRoot.notificationId
                    appName: delegateRoot.appName
                    summary: delegateRoot.summary
                    body: delegateRoot.body
                    iconSource: delegateRoot.icon
                    receivedAt: delegateRoot.receivedAt
                    popup: false
                    onCloseRequested: notificationId =>
                        NotificationService.dismissById(notificationId)
                }
            }

            Text {
                anchors.centerIn: parent
                visible: NotificationService.notificationCount === 0
                text: "No notifications"
                color: Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 13
            }
        }
    }
}
