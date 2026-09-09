import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../../components/common"
import "../../components/state"
import "../../components/theme"

Item {
    id: root

    readonly property var actions: [
        { label: "Shutdown", icon: Icons.power,
            command: ["systemctl", "poweroff"], danger: true },
        { label: "Restart", icon: Icons.restart,
            command: ["systemctl", "reboot"], danger: false },
        { label: "Sleep", icon: Icons.sleep,
            command: ["systemctl", "suspend"], danger: false },
        { label: "Logout", icon: Icons.logout,
            command: ["niri", "msg", "action", "quit", "--skip-confirmation"], danger: false }
    ]

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: ShellMetrics.panelScreenEdgeOverlap + 12
            rightMargin: 16
            topMargin: 16
            bottomMargin: 16
        }
        spacing: 0

        Repeater {
            model: root.actions

            Rectangle {
                id: actionButton

                required property var modelData
                required property int index

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: ShellMetrics.radiusMedium
                color: "transparent"
                clip: true

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: actionHover.hovered ? parent.width : 0
                    radius: actionButton.radius
                    color: actionButton.modelData.danger
                        ? Theme.dangerColor
                        : Theme.accentColor

                    Behavior on width {
                        NumberAnimation {
                            duration: ShellMetrics.pageTransitionDurationMs
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                RowLayout {
                    z: 1
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 12
                        rightMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 12

                    Text {
                        Layout.preferredWidth: 28
                        Layout.alignment: Qt.AlignVCenter
                        text: actionButton.modelData.icon
                        color: actionHover.hovered
                            ? Theme.accentTextColor
                            : Theme.primaryTextColor
                        font.family: Typography.nerdIconFontFamily
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        Behavior on color {
                            ColorAnimation {
                                duration: ShellMetrics.fastAnimationMs
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: actionButton.modelData.label
                        color: actionHover.hovered
                            ? Theme.accentTextColor
                            : Theme.secondaryTextColor
                        font.family: Typography.bodyFontFamily
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        verticalAlignment: Text.AlignVCenter

                        Behavior on color {
                            ColorAnimation {
                                duration: ShellMetrics.fastAnimationMs
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }
                }

                Rectangle {
                    z: 1
                    visible: actionButton.index < root.actions.length - 1
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        leftMargin: 12
                        rightMargin: 12
                    }
                    height: 1
                    color: Theme.surfaceBorderColor
                    opacity: actionHover.hovered ? 0 : 1

                    Behavior on opacity {
                        NumberAnimation {
                            duration: ShellMetrics.fastAnimationMs
                            easing.type: Easing.InOutCubic
                        }
                    }
                }

                HoverHandler {
                    id: actionHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        actionProcess.command = actionButton.modelData.command;
                        OverlayState.hidePowerMenu();
                        actionProcess.running = true;
                    }
                }
            }
        }
    }

    HoverHandler { id: powerMenuHover }

    HoverDismissController {
        active: OverlayState.powerMenuVisible
        panelHovered: powerMenuHover.hovered
        externalHovered: OverlayState.statusBarHovered
        onDismissRequested: OverlayState.hidePowerMenu()
    }

    Process { id: actionProcess }
}
