import QtQuick
import "../../components/common"
import "../../components/theme"

Rectangle {
    id: root

    property string label
    property bool emphasized: false
    property bool transparent: false
    signal clicked

    width: 34
    height: 34
    radius: ShellMetrics.radiusMedium
    color: transparent ? "transparent" : Theme.selectedSurfaceColor

    Text {
        anchors.centerIn: parent
        text: root.label
        color: root.emphasized ? Theme.accentColor : Theme.primaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 11
        font.weight: root.emphasized ? Font.DemiBold : Font.Normal
        font.capitalization: Font.Capitalize
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler { onTapped: root.clicked() }
}
