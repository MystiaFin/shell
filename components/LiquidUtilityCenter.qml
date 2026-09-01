import QtQuick
import QtQuick.Layouts
import "../services"

Item {
    id: root

    readonly property int pageIndex: UtilityCenterState.page === "wifi" ? 1
        : UtilityCenterState.page === "bluetooth" ? 2 : 0
    property bool hoverArmed: false

    focus: UtilityCenterState.visible
    Keys.onEscapePressed: UtilityCenterState.hide()

    component TabButton: Rectangle {
        id: button

        required property string page
        required property string icon
        property bool active: UtilityCenterState.page === page

        Layout.preferredWidth: 44
        Layout.preferredHeight: 38
        radius: 13
        color: active
            ? Theme.statusBarBlueColor
            : tabHover.hovered
                ? Theme.statusBarSurfaceBorderColor
                : Theme.statusBarSurfaceColor

        Text {
            anchors.centerIn: parent
            text: button.icon
            color: button.active
                ? Theme.statusBarBackgroundColor
                : Theme.statusBarTextColor
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 18
        }

        HoverHandler {
            id: tabHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler { onTapped: UtilityCenterState.page = button.page }
    }

    ColumnLayout {
        anchors {
            fill: parent
            topMargin: 28
            rightMargin: LiquidMetrics.edgeContentInset
            bottomMargin: 16
            leftMargin: 16
        }
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            spacing: 8

            Item { Layout.preferredWidth: 42 }
            Item { Layout.fillWidth: true }

            TabButton { page: "notifications"; icon: "󰂚" }
            TabButton { page: "wifi"; icon: "󰖩" }
            TabButton { page: "bluetooth"; icon: "󰂯" }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 38
                radius: 13
                color: wallpaperHover.hovered
                    ? Theme.statusBarAccentColor
                    : Theme.statusBarWorkspaceColor
                border.width: 1
                border.color: Theme.statusBarAccentColor

                Text {
                    anchors.centerIn: parent
                    text: "󰸉"
                    color: wallpaperHover.hovered
                        ? Theme.statusBarBackgroundColor
                        : Theme.statusBarAccentColor
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 19
                }

                HoverHandler {
                    id: wallpaperHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: {
                        WallpaperPickerState.show();
                        UtilityCenterState.hide();
                    }
                }
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
                    NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
                }
            }

            WifiPanel {
                width: pageViewport.width
                height: pageViewport.height
                x: (1 - root.pageIndex) * pageViewport.width

                Behavior on x {
                    NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
                }
            }

            BluetoothPanel {
                width: pageViewport.width
                height: pageViewport.height
                x: (2 - root.pageIndex) * pageViewport.width

                Behavior on x {
                    NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
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

        onHoveredChanged: {
            if (hovered) {
                root.hoverArmed = true;
                closeTimer.stop();
            } else if (root.hoverArmed && UtilityCenterState.visible) {
                closeTimer.restart();
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 180
        onTriggered: {
            if (!widgetHover.hovered && !UtilityCenterState.statusBarHovered)
                UtilityCenterState.hide();
        }
    }

    Timer {
        id: entryTimer
        interval: 650
        onTriggered: {
            if (UtilityCenterState.visible
                    && !widgetHover.hovered
                    && !UtilityCenterState.statusBarHovered)
                UtilityCenterState.hide();
        }
    }

    Connections {
        target: UtilityCenterState

        function onVisibleChanged() {
            if (UtilityCenterState.visible) {
                root.hoverArmed = false;
                entryTimer.restart();
            } else {
                entryTimer.stop();
                closeTimer.stop();
            }
        }

        function onStatusBarHoveredChanged() {
            if (UtilityCenterState.statusBarHovered) {
                closeTimer.stop();
            } else if (UtilityCenterState.visible && !widgetHover.hovered) {
                closeTimer.restart();
            }
        }
    }
}
