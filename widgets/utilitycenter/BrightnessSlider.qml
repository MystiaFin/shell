import QtQuick
import "../../components/theme"
import "../../services"

Rectangle {
    id: root

    property bool dragging: false
    property real displayValue: BrightnessService.brightness

    implicitHeight: 46
    radius: 15
    color: Theme.panelSurfaceColor

    function setBrightnessFromX(pointerX: real): void {
        const nextValue = Math.max(0.01, Math.min(1,
            (pointerX - brightnessTrack.x) / brightnessTrack.width));
        displayValue = nextValue;
        BrightnessService.setBrightness(nextValue);
    }

    Connections {
        target: BrightnessService

        function onBrightnessChanged(): void {
            if (!root.dragging)
                root.displayValue = BrightnessService.brightness;
        }
    }

    Text {
        anchors {
            left: parent.left
            leftMargin: 14
            verticalCenter: parent.verticalCenter
        }
        text: Icons.brightness
        color: Theme.primaryTextColor
        font.family: Typography.nerdIconFontFamily
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
        color: Theme.surfaceBorderColor

        Rectangle {
            width: parent.width * root.displayValue
            height: parent.height
            radius: parent.radius
            color: Theme.accentColor
        }

        Rectangle {
            x: root.displayValue * (parent.width - width)
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            height: 18
            radius: width / 2
            color: Theme.primaryTextColor
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
        text: Math.round(root.displayValue * 100) + "%"
        color: Theme.primaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 12
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignRight
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onPressed: mouse => {
            root.dragging = true;
            root.setBrightnessFromX(mouse.x);
        }
        onPositionChanged: mouse => {
            if (pressed)
                root.setBrightnessFromX(mouse.x);
        }
        onReleased: root.dragging = false
        onCanceled: root.dragging = false
    }
}
