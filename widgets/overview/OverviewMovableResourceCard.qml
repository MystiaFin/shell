import QtQuick

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
        NumberAnimation {
            duration: 700
            easing.type: Easing.InOutCubic
        }
    }

    Behavior on targetY {
        NumberAnimation {
            duration: 700
            easing.type: Easing.InOutCubic
        }
    }
}
