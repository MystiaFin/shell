import QtQuick
import "../theme"

Item {
    id: root

    property real value: 0
    property color ringColor: Theme.accentColor
    property color backgroundColor: Theme.surfaceBorderColor
    property real ringWidth: 3
    property real displayValue: value
    signal scrolled(real delta)
    signal clicked()

    implicitWidth: 24
    implicitHeight: 24

    Behavior on displayValue {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: root.backgroundColor
        border.width: root.ringWidth
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            const context = getContext("2d");
            context.clearRect(0, 0, width, height);
            context.beginPath();
            context.arc(width / 2, height / 2,
                width / 2 - root.ringWidth / 2,
                -Math.PI / 2,
                -Math.PI / 2 + 2 * Math.PI * root.displayValue);
            context.lineCap = "round";
            context.lineWidth = root.ringWidth;
            context.strokeStyle = root.ringColor;
            context.stroke();
        }

        Connections {
            target: root
            function onDisplayValueChanged() { canvas.requestPaint(); }
            function onRingColorChanged() { canvas.requestPaint(); }
            function onBackgroundColorChanged() { canvas.requestPaint(); }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onWheel: wheel => root.scrolled(wheel.angleDelta.y > 0 ? 0.05 : -0.05)
    }
}
