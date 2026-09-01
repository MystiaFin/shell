import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

PanelWindow {
    id: root

    required property var modelData

    property url source: "file:///home/mystiafin/Pictures/Wallpapers/wallpaper_2.jpg"
    property real margin: 0
    property real cornerRadius: 28
    property int imageFillMode: Image.PreserveAspectCrop

    screen: modelData
    color: Theme.wallpaperFallbackColor
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "wallpaper"

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    mask: Region {}

    ClippingRectangle {
        anchors.fill: parent
        anchors.margins: root.margin
        radius: root.cornerRadius
        color: Theme.wallpaperFallbackColor
        contentUnderBorder: true

        Image {
            anchors.fill: parent
            source: root.source
            fillMode: root.imageFillMode
            asynchronous: true
            cache: true
            smooth: true
            mipmap: true
        }
    }
}
