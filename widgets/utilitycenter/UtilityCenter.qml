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

        RowLayout {
            Layout.fillWidth: true
            Layout.minimumHeight: 46
            Layout.preferredHeight: 46
            Layout.maximumHeight: 46
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 38
                Layout.alignment: Qt.AlignVCenter
                radius: ShellMetrics.radiusMedium
                color: modeHover.hovered
                    ? Theme.accentColor : Theme.selectedSurfaceColor
                border.width: 1
                border.color: Theme.accentColor

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutCubic
                    }
                }

                Item {
                    anchors.centerIn: parent
                    width: 22
                    height: 22

                    Text {
                        anchors.centerIn: parent
                        text: Icons.darkMode
                        color: modeHover.hovered
                            ? Theme.accentTextColor : Theme.accentColor
                        font.family: Typography.nerdIconFontFamily
                        font.pixelSize: 19
                        opacity: Theme.lightMode ? 1 : 0
                        scale: Theme.lightMode ? 1 : 0.35
                        rotation: Theme.lightMode ? 0 : -90

                        Behavior on color {
                            ColorAnimation { duration: 300 }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutCubic
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutCubic
                            }
                        }
                        Behavior on rotation {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: 0.5
                        text: Icons.lightMode
                        color: modeHover.hovered
                            ? Theme.accentTextColor : Theme.accentColor
                        font.family: Typography.nerdIconFontFamily
                        font.pixelSize: 19
                        opacity: Theme.lightMode ? 0 : 1
                        scale: Theme.lightMode ? 0.35 : 1
                        rotation: Theme.lightMode ? 90 : 0

                        Behavior on color {
                            ColorAnimation { duration: 300 }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutCubic
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutBack
                            }
                        }
                        Behavior on rotation {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }
                }

                HoverHandler {
                    id: modeHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler { onTapped: Theme.toggleColorMode() }
            }

            BrightnessSlider {
                Layout.fillWidth: true
                Layout.minimumHeight: 46
                Layout.preferredHeight: 46
                Layout.maximumHeight: 46
            }
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
