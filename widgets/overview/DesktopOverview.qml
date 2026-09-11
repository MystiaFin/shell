import Quickshell
import QtQuick
import "../../components/theme"
import "../../services"
import "../clock"

Item {
    id: root

    required property string screenName
    required property rect usableArea
    required property url wallpaperSource
    required property Item wallpaperSourceItem
    property bool shown: false
    property var pendingPlacement: null
    property bool clockJoined: false

    readonly property size clockSize: Qt.size(300, 132)
    readonly property size weatherSize: Qt.size(220, 160)
    readonly property size calendarSize: Qt.size(280, 260)

    opacity: shown ? 1 : 0

    function requestPlacement(): void {
        if (!wallpaperSource.toString() || width <= 0 || height <= 0)
            return;
        FloatingWidgetPlacementService.requestOverviewPlacement(
            screenName, wallpaperSource, width, height, usableArea,
            Theme.primaryTextColor, clockSize, weatherSize, calendarSize);
    }

    function applyPlacement(): void {
        if (!pendingPlacement)
            return;

        const positions = pendingPlacement.positions;
        clockJoined = pendingPlacement.clockJoined;
        clockCard.targetX = positions.clock.xRatio * width;
        clockCard.targetY = positions.clock.yRatio * height;
        weatherCard.targetX = positions.weather.xRatio * width;
        weatherCard.targetY = positions.weather.yRatio * height;
        calendarCard.targetX = positions.calendar.xRatio * width;
        calendarCard.targetY = positions.calendar.yRatio * height;
    }

    Behavior on opacity {
        NumberAnimation {
            duration: ShellMetrics.fastAnimationMs
            easing.type: Easing.InOutCubic
        }
    }

    FloatingClock {
        id: clockCard

        property real targetX: (root.width - width) / 2
        property real targetY: root.usableArea.y
            + (root.usableArea.height - height) / 2
        x: targetX
        y: targetY
        width: root.clockSize.width
        height: root.clockSize.height
        contentAlignment: x + width / 2 < root.width / 2
            ? Text.AlignLeft : Text.AlignRight

        Behavior on targetX { OverviewMovement {} }
        Behavior on targetY { OverviewMovement {} }
    }

    OverviewWeather {
        id: weatherCard

        property real targetX: (root.width - width) / 2
        property real targetY: root.usableArea.y
        x: targetX
        y: targetY
        width: root.weatherSize.width
        height: root.weatherSize.height
        wallpaperSourceItem: root.wallpaperSourceItem
        wallpaperRect: Qt.rect(x, y, width, height)

        Behavior on targetX { OverviewMovement {} }
        Behavior on targetY { OverviewMovement {} }
    }

    OverviewCalendar {
        id: calendarCard

        property real targetX: (root.width - width) / 2
        property real targetY: weatherCard.targetY + weatherCard.height + 12
        x: targetX
        y: targetY
        width: root.calendarSize.width
        height: root.calendarSize.height
        wallpaperSourceItem: root.wallpaperSourceItem
        wallpaperRect: Qt.rect(x, y, width, height)

        Behavior on targetX { OverviewMovement {} }
        Behavior on targetY { OverviewMovement {} }
    }

    component OverviewMovement: NumberAnimation {
        duration: 700
        easing.type: Easing.InOutCubic
    }

    Timer {
        id: placementApplyDelay
        interval: 600
        onTriggered: root.applyPlacement()
    }

    Connections {
        target: FloatingWidgetPlacementService

        function onOverviewPlacementReady(key, source, placement): void {
            if (key !== root.screenName
                    || source !== root.wallpaperSource.toString())
                return;
            root.pendingPlacement = placement;
            placementApplyDelay.restart();
        }
    }

    onWallpaperSourceChanged: {
        placementApplyDelay.stop();
        requestPlacement();
    }
    onWidthChanged: requestPlacement()
    onHeightChanged: requestPlacement()
    Component.onCompleted: requestPlacement()
}
