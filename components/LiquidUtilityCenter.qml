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
            ? Theme.statusBarAccentColor
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

        Rectangle {
            id: brightnessControl

            property bool dragging: false
            property real displayValue: BrightnessService.brightness

            function setFromX(pointerX): void {
                const nextValue = Math.max(0.01, Math.min(1,
                    (pointerX - brightnessTrack.x) / brightnessTrack.width));
                displayValue = nextValue;
                BrightnessService.setBrightness(nextValue);
            }

            Connections {
                target: BrightnessService
                function onBrightnessChanged(): void {
                    if (!brightnessControl.dragging)
                        brightnessControl.displayValue = BrightnessService.brightness;
                }
            }

            Layout.fillWidth: true
            Layout.preferredHeight: 46
            radius: 15
            color: Theme.statusBarSurfaceColor

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                text: "󰃠"
                color: Theme.statusBarTextColor
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 18
            }

            Rectangle {
                id: brightnessTrack

                anchors {
                    left: parent.left
                    leftMargin: 48
                    right: brightnessPercentage.left
                    rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                height: 8
                radius: height / 2
                color: Theme.statusBarSurfaceBorderColor

                Rectangle {
                    width: parent.width * brightnessControl.displayValue
                    height: parent.height
                    radius: parent.radius
                    color: Theme.statusBarAccentColor
                }

                Rectangle {
                    x: brightnessControl.displayValue * (parent.width - width)
                    anchors.verticalCenter: parent.verticalCenter
                    width: 18
                    height: 18
                    radius: width / 2
                    color: Theme.statusBarTextColor
                }
            }

            Text {
                id: brightnessPercentage

                anchors {
                    right: parent.right
                    rightMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                width: 38
                text: Math.round(brightnessControl.displayValue * 100) + "%"
                color: Theme.statusBarTextColor
                font.family: "Poppins"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignRight
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => {
                    brightnessControl.dragging = true;
                    brightnessControl.setFromX(mouse.x);
                }
                onPositionChanged: mouse => {
                    if (pressed)
                        brightnessControl.setFromX(mouse.x);
                }
                onReleased: brightnessControl.dragging = false
                onCanceled: brightnessControl.dragging = false
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
