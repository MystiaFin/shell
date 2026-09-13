import QtQuick
import Quickshell.Widgets
import "../../components/theme"

Item {
    id: root

    required property url source
    required property real prominence
    signal selectionRequested()

    scale: 0.4 + prominence * 0.95
    opacity: 0.55 + prominence * 0.45
    z: Math.round(prominence * 10)

    ClippingRectangle {
        anchors.fill: parent
        radius: ShellMetrics.radiusLarge
        color: Theme.selectedSurfaceColor
        contentUnderBorder: true

        Image {
            anchors.fill: parent
            source: root.source
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            mipmap: true
        }

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: (1 - root.prominence) * 0.78
        }

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler { onTapped: root.selectionRequested() }
    }
}
