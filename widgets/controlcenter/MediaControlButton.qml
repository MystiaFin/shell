import QtQuick
import "../../components/theme"

Rectangle {
    id: mediaControlButton

    required property string icon
    property bool primaryAction: false
    signal clicked()

    implicitWidth: primaryAction ? 44 : 38
    implicitHeight: primaryAction ? 44 : 38
    radius: height / 2
    color: primaryAction
        ? Theme.accentColor
        : buttonHover.hovered
            ? Theme.surfaceBorderColor
            : "transparent"

    Text {
        anchors.centerIn: parent
        text: mediaControlButton.icon
        color: mediaControlButton.primaryAction
            ? Theme.shellBackgroundColor
            : Theme.primaryTextColor
        font.family: Typography.nerdIconFontFamily
        font.pixelSize: mediaControlButton.primaryAction ? 21 : 18
    }

    HoverHandler {
        id: buttonHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler { onTapped: mediaControlButton.clicked() }
}
