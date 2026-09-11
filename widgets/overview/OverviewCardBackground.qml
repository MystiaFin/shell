import Quickshell.Widgets
import QtQuick
import QtQuick.Effects
import "../../components/theme"

Item {
    id: root

    required property Item wallpaperSourceItem
    required property rect wallpaperRect
    readonly property real blurMargin: 48
    readonly property real cropX: Math.max(0,
        wallpaperRect.x - blurMargin)
    readonly property real cropY: Math.max(0,
        wallpaperRect.y - blurMargin)
    readonly property real cropRight: Math.min(wallpaperSourceItem.width,
        wallpaperRect.x + wallpaperRect.width + blurMargin)
    readonly property real cropBottom: Math.min(wallpaperSourceItem.height,
        wallpaperRect.y + wallpaperRect.height + blurMargin)

    ClippingRectangle {
        anchors.fill: parent
        radius: ShellMetrics.radiusExtraLarge
        color: "transparent"
        contentUnderBorder: true

        ShaderEffectSource {
            id: wallpaperCrop

            x: root.cropX - root.wallpaperRect.x
            y: root.cropY - root.wallpaperRect.y
            width: Math.max(1, root.cropRight - root.cropX)
            height: Math.max(1, root.cropBottom - root.cropY)
            sourceItem: root.wallpaperSourceItem
            hideSource: true
            sourceRect: Qt.rect(root.cropX, root.cropY, width, height)
            textureSize: Qt.size(width, height)
            live: true
            smooth: true
        }

        MultiEffect {
            anchors.fill: wallpaperCrop
            source: wallpaperCrop
            autoPaddingEnabled: false
            blurEnabled: true
            blur: 1
            blurMax: 64
            blurMultiplier: 1.5
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.panelSurfaceColor
            opacity: 0.32
        }
    }
}
