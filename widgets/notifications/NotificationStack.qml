import QtQuick
import "../../components/theme"
import "../../services"

Item {
    id: root

    property real maximumHeight: 600
    readonly property real desiredHeight: NotificationService.popupNotificationCount > 0
        ? Math.min(maximumHeight, list.contentHeight + 48)
        : 1

    ListView {
        id: list

        anchors {
            fill: parent
            topMargin: 16
            rightMargin: ShellMetrics.panelContentInsetFromEdge
            bottomMargin: 32
            leftMargin: 16
        }
        model: NotificationService.popupNotificationModel
        spacing: 8
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        onCountChanged: if (count > 0) positionViewAtEnd()

        remove: Transition {
            NumberAnimation {
                property: "slideOffset"
                from: 0
                to: list.width
                duration: 240
                easing.type: Easing.InCubic
            }
        }

        displaced: Transition {
            NumberAnimation {
                property: "y"
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        delegate: Item {
            id: delegateRoot

            required property int notificationId
            required property string appName
            required property string summary
            required property string body
            required property string icon
            required property var receivedAt
            property real slideOffset: 0

            width: list.width
            height: card.implicitHeight
            transform: Translate { x: delegateRoot.slideOffset }

            NotificationCard {
                id: card
                anchors.fill: parent
                notificationId: delegateRoot.notificationId
                appName: delegateRoot.appName
                summary: delegateRoot.summary
                body: delegateRoot.body
                iconSource: delegateRoot.icon
                receivedAt: delegateRoot.receivedAt
                popup: true
                onCloseRequested: notificationId =>
                    NotificationService.removePopupById(notificationId)
            }
        }
    }
}
