import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../services"

Item {
    id: root

    property real topPadding: LiquidMetrics.edgeOverlap + 28
    property bool hoverArmed: false

    function formatTime(seconds) {
        const minutes = Math.floor(Math.max(0, seconds) / 60);
        const remainder = Math.floor(Math.max(0, seconds) % 60);
        return minutes + ":" + (remainder < 10 ? "0" : "") + remainder;
    }

    component AudioControl: Item {
        id: control

        required property string icon
        required property real value
        property color accentColor: Theme.statusBarBlueColor
        property bool muted: false
        property bool dragging: false
        property real displayValue: value
        signal valueMoved(real value)

        onValueChanged: {
            if (!dragging)
                displayValue = value;
        }

        Layout.preferredWidth: 48
        Layout.fillHeight: true

        ColumnLayout {
            anchors {
                fill: parent
                margins: 4
            }
            spacing: 8

            Item {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                Layout.alignment: Qt.AlignHCenter

                Text {
                    anchors.centerIn: parent
                    text: control.icon
                    color: Theme.statusBarTextColor
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 19
                }
            }

            Item {
                id: verticalFader

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 120

                Rectangle {
                    id: faderTrack

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: 22
                    radius: width / 2
                    color: Theme.statusBarSurfaceBorderColor

                    Rectangle {
                        anchors {
                            right: parent.right
                            bottom: parent.bottom
                            left: parent.left
                        }
                        height: control.displayValue * parent.height
                        radius: parent.radius
                        color: control.muted
                            ? Theme.statusBarMutedColor
                            : control.accentColor
                    }
                }

                Rectangle {
                    id: faderHandle

                    anchors.horizontalCenter: parent.horizontalCenter
                    y: (1 - control.displayValue) * (parent.height - height)
                    width: 22
                    height: 22
                    radius: width / 2
                    color: Theme.statusBarTextColor

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: mouseY >= faderHandle.y
                        && mouseY <= faderHandle.y + faderHandle.height
                        ? Qt.PointingHandCursor
                        : Qt.ArrowCursor

                    function setFromY(pointerY) {
                        const handleRadius = faderHandle.height / 2;
                        const travel = Math.max(1, height - faderHandle.height);
                        const nextValue = 1 - (pointerY - handleRadius) / travel;
                        control.displayValue = Math.max(0, Math.min(1, nextValue));
                        control.valueMoved(control.displayValue);
                    }

                    onPressed: mouse => {
                        control.dragging = true;
                        setFromY(mouse.y);
                    }
                    onPositionChanged: mouse => {
                        if (pressed)
                            setFromY(mouse.y);
                    }
                    onReleased: {
                        control.dragging = false;
                        control.displayValue = control.value;
                    }
                    onCanceled: {
                        control.dragging = false;
                        control.displayValue = control.value;
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Math.round(control.displayValue * 100) + "%"
                color: Theme.statusBarTextColor
                font.family: "Poppins"
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

        }
    }

    component MediaButton: Rectangle {
        id: button

        required property string icon
        property bool primary: false
        signal clicked()

        implicitWidth: primary ? 44 : 38
        implicitHeight: primary ? 44 : 38
        radius: height / 2
        color: primary
            ? Theme.statusBarBlueColor
            : pointer.hovered
                ? Theme.statusBarSurfaceBorderColor
                : "transparent"

        Text {
            anchors.centerIn: parent
            text: button.icon
            color: button.primary
                ? Theme.statusBarBackgroundColor
                : Theme.statusBarTextColor
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: button.primary ? 21 : 18
        }

        HoverHandler {
            id: pointer
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler { onTapped: button.clicked() }
    }

    GridLayout {
        anchors {
            fill: parent
            topMargin: root.topPadding
            rightMargin: 18
            bottomMargin: 18
            leftMargin: 18
        }
        columns: 2
        columnSpacing: 14

        Rectangle {
            Layout.preferredWidth: 120
            Layout.fillHeight: true
            radius: 20
            color: Theme.statusBarSurfaceColor

            RowLayout {
                width: 100
                anchors {
                    top: parent.top
                    topMargin: 6
                    bottom: parent.bottom
                    bottomMargin: 6
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 4

                AudioControl {
                    icon: "󰕾"
                    value: AudioService.volume
                    muted: AudioService.muted
                    accentColor: Theme.statusBarBlueColor
                    onValueMoved: value => AudioService.setVolume(value)
                }

                AudioControl {
                    icon: "󰍬"
                    value: AudioService.microphoneVolume
                    muted: AudioService.microphoneMuted
                    accentColor: Theme.statusBarRedColor
                    onValueMoved: value => AudioService.setMicrophoneVolume(value)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 22
            color: Theme.statusBarSurfaceColor

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 18
                }
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 112
                    spacing: 14

                    ClippingRectangle {
                        Layout.preferredWidth: 112
                        Layout.preferredHeight: 112
                        radius: 14
                        color: Theme.statusBarSurfaceBorderColor

                        Image {
                            anchors.fill: parent
                            source: MediaService.artUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            smooth: true
                            visible: MediaService.artUrl !== ""
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: MediaService.artUrl === ""
                            text: "󰝚"
                            color: Theme.statusBarMutedColor
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 42
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 4

                        Item { Layout.fillHeight: true }

                        Text {
                            Layout.fillWidth: true
                            text: MediaService.title || "Nothing playing"
                            color: Theme.statusBarTextColor
                            font.family: "Poppins"
                            font.pixelSize: 17
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Text {
                            Layout.fillWidth: true
                            text: MediaService.artist || "Open Spotify or another media player"
                            color: Theme.statusBarMutedColor
                            font.family: "Poppins"
                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: MediaService.album !== ""
                            text: MediaService.album
                            color: Theme.launcherSecondaryTextColor
                            font.family: "Poppins"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }

                        Item { Layout.fillHeight: true }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24

                    Row {
                        id: cavaRow
                        anchors.fill: parent
                        spacing: 3

                        Repeater {
                            model: CavaService.bars

                            Item {
                                required property real modelData

                                width: (cavaRow.width - (CavaService.barCount - 1) * cavaRow.spacing)
                                    / CavaService.barCount
                                height: cavaRow.height

                                Rectangle {
                                    anchors {
                                        right: parent.right
                                        bottom: parent.bottom
                                        left: parent.left
                                    }
                                    height: Math.max(3, parent.height * modelData)
                                    radius: width / 2
                                    color: Theme.statusBarBlueColor

                                    Behavior on height {
                                        NumberAnimation {
                                            duration: 65
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: root.formatTime(MediaService.position)
                        color: Theme.statusBarMutedColor
                        font.family: "Poppins"
                        font.pixelSize: 11
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 5
                        radius: height / 2
                        color: Theme.statusBarSurfaceBorderColor

                        Rectangle {
                            width: MediaService.length > 0
                                ? Math.min(parent.width,
                                    MediaService.position / MediaService.length * parent.width)
                                : 0
                            height: parent.height
                            radius: parent.radius
                            color: Theme.statusBarBlueColor

                            Behavior on width { NumberAnimation { duration: 200 } }
                        }
                    }

                    Text {
                        text: root.formatTime(MediaService.length)
                        color: Theme.statusBarMutedColor
                        font.family: "Poppins"
                        font.pixelSize: 11
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    spacing: 10

                    Item { Layout.fillWidth: true }

                    MediaButton {
                        icon: "󰒮"
                        onClicked: MediaService.previous()
                    }
                    MediaButton {
                        primary: true
                        icon: MediaService.playing ? "󰏤" : "󰐊"
                        onClicked: MediaService.playPause()
                    }
                    MediaButton {
                        icon: "󰒭"
                        onClicked: MediaService.next()
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }
    }

    HoverHandler {
        id: widgetHover

        onHoveredChanged: {
            if (hovered) {
                root.hoverArmed = true;
                closeTimer.stop();
            } else if (root.hoverArmed && ControlCenterState.visible) {
                closeTimer.restart();
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 180
        onTriggered: {
            if (!widgetHover.hovered && !ControlCenterState.statusBarHovered)
                ControlCenterState.hide();
        }
    }

    Timer {
        id: entryTimer
        interval: 650
        onTriggered: {
            if (ControlCenterState.visible
                    && !widgetHover.hovered
                    && !ControlCenterState.statusBarHovered)
                ControlCenterState.hide();
        }
    }

    Connections {
        target: ControlCenterState

        function onVisibleChanged() {
            if (ControlCenterState.visible) {
                root.hoverArmed = false;
                entryTimer.restart();
            } else {
                entryTimer.stop();
                closeTimer.stop();
            }
        }
    }

    Connections {
        target: ControlCenterState

        function onStatusBarHoveredChanged() {
            if (ControlCenterState.statusBarHovered) {
                closeTimer.stop();
            } else if (ControlCenterState.visible && !widgetHover.hovered) {
                closeTimer.restart();
            }
        }
    }
}
