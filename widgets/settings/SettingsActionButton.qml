import QtQuick
import "../../components/common"
import "../../components/theme"

Rectangle {
    id: root

    required property string label
    property bool danger: false
    signal clicked

    width: actionLabel.implicitWidth + 28
    height: 40
    radius: ShellMetrics.radiusMedium
    color: danger ? Theme.dangerColor : Theme.selectedSurfaceColor

    Text {
        id: actionLabel

        anchors.centerIn: parent
        text: root.label
        color: root.danger ? Theme.accentTextColor : Theme.primaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 12
        font.weight: Font.DemiBold
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler { onTapped: root.clicked() }
}
