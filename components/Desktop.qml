import Quickshell
import QtQuick
import "../services"
import "../widgets"

WidgetOverlay {
    id: root

    required property var modelData

    screen: modelData

    EdgeWidget {
        id: utilityCenterWidget

        host: root
        edge: EdgeWidget.Right
        edgeAlignment: EdgeWidget.Start
        y: -10
        edgeOffset: WidgetMetrics.edgeOverlap
        shown: UtilityCenterState.visible
        wantsKeyboardFocus: true
        closedWidthScale: 1
        targetWidth: 360
        targetHeight: Math.max(1, Math.min(800, root.height - 96))
        radius: WidgetMetrics.widgetRadius

        UtilityCenter {
            anchors.fill: parent
        }
    }

    EdgeWidget {
        id: controlCenterWidget

        host: root
        edge: EdgeWidget.Top
        edgeAlignment: EdgeWidget.Center
        edgeOffset: WidgetMetrics.edgeOverlap
        shown: ControlCenterState.visible
        targetWidth: Math.max(1, Math.min(780, root.width - 64))
        targetHeight: 410
        radius: WidgetMetrics.widgetRadius

        ControlCenter {
            anchors.fill: parent
        }
    }

    EdgeWidget {
        id: launcherWidget

        host: root
        edge: EdgeWidget.Bottom
        edgeAlignment: EdgeWidget.Center
        edgeOffset: WidgetMetrics.edgeOverlap
        shown: LauncherState.launcherVisible
        wantsKeyboardFocus: true
        focusTarget: launcher.focusTarget

        targetWidth: Math.max(1, Math.min(620, root.width - 80))
        targetHeight: launcher.desiredHeight
        radius: WidgetMetrics.widgetRadius
        resizeDuration: launcher.resizeDuration

        ApplicationLauncher {
            id: launcher
            anchors.fill: parent
            shown: launcherWidget.shown
            maximumHeight: Math.max(1, Math.min(620, root.height - 60))
            bottomPadding: WidgetMetrics.edgeContentInset

            onCloseRequested: LauncherState.hide()
        }
    }

    EdgeWidget {
        id: notificationWidget

        host: root
        edge: EdgeWidget.Right
        edgeAlignment: EdgeWidget.End
        alongEdgeOffset: -24
        edgeOffset: WidgetMetrics.edgeOverlap
        shown: NotificationService.popupCount > 0 && !UtilityCenterState.visible
        closedWidthScale: 1
        targetWidth: 380
        targetHeight: notificationStack.desiredHeight
        radius: WidgetMetrics.widgetRadius
        resizeDuration: 240

        NotificationStack {
            id: notificationStack
            anchors.fill: parent
            maximumHeight: Math.max(1, root.height - 112)
        }
    }

}
