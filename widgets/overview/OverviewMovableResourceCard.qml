import QtQuick
import "../../components/common"
import "../../components/theme"

OverviewResourceCard {
    id: root

    required property var overview
    required property size cardSize
    property real targetX: 0
    property real targetY: 0

    x: targetX
    y: targetY
    width: cardSize.width
    height: cardSize.height
    wallpaperSourceItem: overview.wallpaperSourceItem
    wallpaperRect: Qt.rect(x, y, width, height)

    Behavior on targetX {
        enabled: root.overview.placementReady
        MotionAnimation {
            type: MotionAnimation.SlowSpatial
            duration: ShellMetrics.floatingWidgetTransitionDurationMs
        }
    }

    Behavior on targetY {
        enabled: root.overview.placementReady
        MotionAnimation {
            type: MotionAnimation.SlowSpatial
            duration: ShellMetrics.floatingWidgetTransitionDurationMs
        }
    }
}
