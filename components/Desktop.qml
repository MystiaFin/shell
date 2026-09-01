import Quickshell
import QtQuick
import "../services"

LiquidWidgetHost {
    id: root

    required property var modelData

    screen: modelData

    LiquidWidget {
        id: utilityCenterWidget

        host: root
        edge: LiquidWidget.Right
        edgeAlignment: LiquidWidget.Start
        y: -10
        edgeOffset: LiquidMetrics.edgeOverlap
        shown: UtilityCenterState.visible
        wantsKeyboardFocus: true
        closedWidthScale: 1
        targetWidth: 360
        targetHeight: Math.max(1, Math.min(800, root.height - 96))
        radius: LiquidMetrics.widgetRadius

        LiquidUtilityCenter {
            anchors.fill: parent
        }
    }

    LiquidWidget {
        id: controlCenterWidget

        host: root
        edge: LiquidWidget.Top
        edgeAlignment: LiquidWidget.Center
        edgeOffset: LiquidMetrics.edgeOverlap
        shown: ControlCenterState.visible
        targetWidth: Math.max(1, Math.min(780, root.width - 64))
        targetHeight: 410
        radius: LiquidMetrics.widgetRadius

        LiquidControlCenter {
            anchors.fill: parent
        }
    }

    LiquidWidget {
        id: launcherWidget

        host: root
        edge: LiquidWidget.Bottom
        edgeAlignment: LiquidWidget.Center
        edgeOffset: LiquidMetrics.edgeOverlap
        shown: LauncherState.launcherVisible
        wantsKeyboardFocus: true
        focusTarget: launcher.focusTarget

        targetWidth: Math.max(1, Math.min(620, root.width - 80))
        targetHeight: launcher.desiredHeight
        radius: LiquidMetrics.widgetRadius
        resizeDuration: launcher.resizeDuration

        ApplicationLauncher {
            id: launcher
            anchors.fill: parent
            shown: launcherWidget.shown
            maximumHeight: Math.max(1, Math.min(620, root.height - 60))
            bottomPadding: LiquidMetrics.edgeContentInset

            onCloseRequested: LauncherState.hide()
        }
    }

    LiquidWidget {
        id: notificationWidget

        host: root
        edge: LiquidWidget.Right
        edgeAlignment: LiquidWidget.End
        alongEdgeOffset: -24
        edgeOffset: LiquidMetrics.edgeOverlap
        shown: NotificationService.popupCount > 0 && !UtilityCenterState.visible
        closedWidthScale: 1
        targetWidth: 380
        targetHeight: notificationStack.desiredHeight
        radius: LiquidMetrics.widgetRadius
        resizeDuration: 240

        LiquidNotificationStack {
            id: notificationStack
            anchors.fill: parent
            maximumHeight: Math.max(1, root.height - 112)
        }
    }

}
