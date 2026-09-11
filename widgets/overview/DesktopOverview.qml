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
    property string requestedFingerprint: ""

    readonly property size clockSize: Qt.size(300, 132)
    readonly property size weatherSize: Qt.size(220, 160)
    readonly property size calendarSize: Qt.size(280, 260)
    readonly property size resourceSize: Qt.size(190, 125)
    readonly property color placementTextColor: Theme.primaryTextColor

    opacity: shown ? 1 : 0

    function requestPlacement(): void {
        if (!wallpaperSource.toString() || width <= 0 || height <= 0)
            return;
        const fingerprint = [wallpaperSource.toString(), width, height,
            usableArea.x, usableArea.y, usableArea.width, usableArea.height,
            placementTextColor.toString(), CpuService.gpuAvailable].join("|");
        if (fingerprint === requestedFingerprint)
            return;
        requestedFingerprint = fingerprint;
        FloatingWidgetPlacementService.requestOverviewPlacement(
            screenName, wallpaperSource, width, height, usableArea,
            placementTextColor, clockSize, weatherSize, calendarSize,
            resourceSize, CpuService.gpuAvailable);
    }

    function schedulePlacement(): void {
        placementRequestDelay.restart();
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
        if (!positions.cpuTemperature || !positions.cpuUsage)
            return;
        cpuTemperatureCard.targetX = positions.cpuTemperature.xRatio * width;
        cpuTemperatureCard.targetY = positions.cpuTemperature.yRatio * height;
        cpuUsageCard.targetX = positions.cpuUsage.xRatio * width;
        cpuUsageCard.targetY = positions.cpuUsage.yRatio * height;
        if (positions.gpuTemperature) {
            gpuTemperatureCard.targetX = positions.gpuTemperature.xRatio * width;
            gpuTemperatureCard.targetY = positions.gpuTemperature.yRatio * height;
        }
    }

    function temperatureColor(value: real): color {
        return value < 70 ? Theme.successColor
            : value < 85 ? Theme.accentColor : Theme.dangerColor;
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

    OverviewResourceCard {
        id: cpuTemperatureCard

        property real targetX: root.usableArea.x + root.usableArea.width - width
        property real targetY: root.usableArea.y
        x: targetX
        y: targetY
        width: root.resourceSize.width
        height: root.resourceSize.height
        wallpaperSourceItem: root.wallpaperSourceItem
        wallpaperRect: Qt.rect(x, y, width, height)
        label: "CPU TEMPERATURE"
        value: CpuService.temperatureAvailable
            ? Math.round(CpuService.temperature) + "°C" : "--°C"
        detail: ""
        progress: CpuService.temperature / 100
        accentColor: root.temperatureColor(CpuService.temperature)

        Behavior on targetX { OverviewMovement {} }
        Behavior on targetY { OverviewMovement {} }
    }

    OverviewResourceCard {
        id: cpuUsageCard

        property real targetX: cpuTemperatureCard.targetX
        property real targetY: cpuTemperatureCard.targetY + height + 12
        x: targetX
        y: targetY
        width: root.resourceSize.width
        height: root.resourceSize.height
        wallpaperSourceItem: root.wallpaperSourceItem
        wallpaperRect: Qt.rect(x, y, width, height)
        label: "CPU USAGE"
        value: CpuService.percent + "%"
        detail: ""
        progress: CpuService.usage
        accentColor: CpuService.usage < 0.5 ? Theme.successColor
            : CpuService.usage < 0.8 ? Theme.accentColor : Theme.dangerColor

        Behavior on targetX { OverviewMovement {} }
        Behavior on targetY { OverviewMovement {} }
    }

    OverviewResourceCard {
        id: gpuTemperatureCard

        property real targetX: cpuUsageCard.targetX
        property real targetY: cpuUsageCard.targetY + height + 12
        x: targetX
        y: targetY
        width: root.resourceSize.width
        height: root.resourceSize.height
        visible: CpuService.gpuAvailable
        wallpaperSourceItem: root.wallpaperSourceItem
        wallpaperRect: Qt.rect(x, y, width, height)
        label: "GPU TEMPERATURE"
        value: Math.round(CpuService.gpuTemperature) + "°C"
        detail: CpuService.gpuName
        progress: CpuService.gpuTemperature / 100
        accentColor: root.temperatureColor(CpuService.gpuTemperature)

        Behavior on targetX { OverviewMovement {} }
        Behavior on targetY { OverviewMovement {} }
    }

    component OverviewMovement: NumberAnimation {
        duration: 700
        easing.type: Easing.InOutCubic
    }

    Timer {
        id: placementRequestDelay
        interval: 50
        onTriggered: root.requestPlacement()
    }

    Connections {
        target: FloatingWidgetPlacementService

        function onOverviewPlacementReady(key, source, placement): void {
            if (key !== root.screenName
                    || source !== root.wallpaperSource.toString())
                return;
            root.pendingPlacement = placement;
            root.applyPlacement();
        }
    }

    onWallpaperSourceChanged: {
        pendingPlacement = null;
        schedulePlacement();
    }
    onUsableAreaChanged: schedulePlacement()
    onPlacementTextColorChanged: schedulePlacement()
    Connections {
        target: CpuService
        function onGpuAvailableChanged(): void { root.schedulePlacement(); }
    }
    onWidthChanged: schedulePlacement()
    onHeightChanged: schedulePlacement()
    Component.onCompleted: schedulePlacement()
}
