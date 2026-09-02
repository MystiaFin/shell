import QtQuick
import QtQuick.Layouts
import "../../components/common"
import "../../components/state"
import "../../components/theme"
import "../connectivity"
import "../notifications"

Item {
    id: root

    readonly property int pageIndex: OverlayState.utilityPage === "wifi" ? 1
        : OverlayState.utilityPage === "bluetooth" ? 2 : 0
    focus: OverlayState.utilityCenterVisible
    Keys.onEscapePressed: OverlayState.hideUtilityCenter()

    ColumnLayout {
        anchors {
            fill: parent
            topMargin: 28
            rightMargin: ShellMetrics.panelContentInsetFromEdge
            bottomMargin: 16
            leftMargin: 16
        }
        spacing: 12

        UtilityTabBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            currentPage: OverlayState.utilityPage
            onPageRequested: page => OverlayState.utilityPage = page
            onWallpaperRequested: OverlayState.showWallpaperPicker()
        }

        BrightnessSlider {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
        }

        Item {
            id: pageViewport

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            NotificationPanel {
                width: pageViewport.width
                height: pageViewport.height
                x: (0 - root.pageIndex) * pageViewport.width

                Behavior on x {
                    NumberAnimation { duration: ShellMetrics.pageTransitionDurationMs; easing.type: Easing.OutCubic }
                }
            }

            WifiPanel {
                width: pageViewport.width
                height: pageViewport.height
                x: (1 - root.pageIndex) * pageViewport.width

                Behavior on x {
                    NumberAnimation { duration: ShellMetrics.pageTransitionDurationMs; easing.type: Easing.OutCubic }
                }
            }

            BluetoothPanel {
                width: pageViewport.width
                height: pageViewport.height
                x: (2 - root.pageIndex) * pageViewport.width

                Behavior on x {
                    NumberAnimation { duration: ShellMetrics.pageTransitionDurationMs; easing.type: Easing.OutCubic }
                }
            }
        }

        CalendarPanel {
            Layout.fillWidth: true
            Layout.preferredHeight: 260
        }
    }

    HoverHandler {
        id: widgetHover
    }

    HoverDismissController {
        active: OverlayState.utilityCenterVisible
        panelHovered: widgetHover.hovered
        externalHovered: OverlayState.statusBarHovered
        onDismissRequested: OverlayState.hideUtilityCenter()
    }
}
