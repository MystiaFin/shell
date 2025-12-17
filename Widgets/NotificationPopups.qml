import Quickshell
import QtQuick
import "../Services" as Services
import "../Components" as Component

Scope {
    Services.NotificationService {
        id: notificationService
    }

    PanelWindow {
        id: notifContainer
        anchors {
            top: true
            right: true
        }
        margins {
            top: -6
        }

        width: 360
        height: (notifView.count > 0 && notifView.contentHeight > 0) ? notifView.contentHeight + 40 : 0
        color: "transparent"

        ListView {
            id: notifView
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            model: notificationService.notificationModel
            interactive: false

            displaced: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            delegate: Component.NotificationComponent {}
        }
    }
}
