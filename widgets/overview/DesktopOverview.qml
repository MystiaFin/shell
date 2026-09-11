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
    property string requestedFingerprint: ""

    readonly property size clockSize: Qt.size(300, 132)
    readonly property size weatherSize: Qt.size(220, 160)
    readonly property size calendarSize: Qt.size(280, 260)
    readonly property size resourceSize: Qt.size(190, 125)
    readonly property size environmentSize: Qt.size(190, 125)
    readonly property color placementTextColor: Theme.primaryTextColor

    visible: shown || opacity > 0
    opacity: shown ? 1 : 0

    function requestPlacement(): void {
        if (!wallpaperSource.toString() || width <= 0 || height <= 0)
            return;
        const fingerprint = [wallpaperSource.toString(), width, height,
            usableArea.x, usableArea.y, usableArea.width, usableArea.height,
            placementTextColor.toString(), CpuService.gpuAvailable,
            WeatherService.airQualityAvailable].join("|");
        if (fingerprint === requestedFingerprint)
            return;
        requestedFingerprint = fingerprint;
        FloatingWidgetPlacementService.requestOverviewPlacement({
            key: screenName,
            source: wallpaperSource,
            screenWidth: width,
            screenHeight: height,
            usableArea: usableArea,
            textColor: placementTextColor,
            clockSize: clockSize,
            weatherSize: weatherSize,
            calendarSize: calendarSize,
            resourceSize: resourceSize,
            environmentSize: environmentSize,
            gpuAvailable: CpuService.gpuAvailable,
            airQualityAvailable: WeatherService.airQualityAvailable
        });
    }

    function schedulePlacement(): void {
        placementRequestDelay.restart();
    }

    function moveCard(card: var, position: var): void {
        if (!position)
            return;
        card.targetX = position.xRatio * width;
        card.targetY = position.yRatio * height;
    }

    function applyPlacement(): void {
        if (!pendingPlacement)
            return;

        const positions = pendingPlacement.positions;
        moveCard(clockCard, positions.clock);
        moveCard(weatherCard, positions.weather);
        moveCard(calendarCard, positions.calendar);
        moveCard(cpuTemperatureCard, positions.cpuTemperature);
        moveCard(cpuUsageCard, positions.cpuUsage);
        moveCard(gpuTemperatureCard, positions.gpuTemperature);
        moveCard(uvIndexCard, positions.uvIndex);
        moveCard(humidityCard, positions.humidity);
        moveCard(airQualityCard, positions.airQuality);
    }

    function temperatureColor(value: real): color {
        return value < 70 ? Theme.successColor
            : value < 85 ? Theme.accentColor : Theme.dangerColor;
    }

    function uvColor(value: real): color {
        return value < 3 ? Theme.successColor
            : value < 6 ? Theme.accentColor : Theme.dangerColor;
    }

    function airQualityColor(value: real): color {
        return value <= 50 ? Theme.successColor
            : value <= 100 ? Theme.accentColor : Theme.dangerColor;
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

    OverviewMovableResourceCard {
        id: cpuTemperatureCard

        overview: root

        targetX: root.usableArea.x + root.usableArea.width - width
        targetY: root.usableArea.y
        cardSize: root.resourceSize
        label: "CPU TEMPERATURE"
        icon: Icons.temperature
        value: CpuService.temperatureAvailable
            ? Math.round(CpuService.temperature) + "°C" : "--°C"
        detail: ""
        progress: CpuService.temperature / 100
        accentColor: root.temperatureColor(CpuService.temperature)
    }

    OverviewMovableResourceCard {
        id: cpuUsageCard

        overview: root

        targetX: cpuTemperatureCard.targetX
        targetY: cpuTemperatureCard.targetY + height + 12
        cardSize: root.resourceSize
        label: "CPU USAGE"
        icon: Icons.cpu
        value: CpuService.percent + "%"
        detail: ""
        progress: CpuService.usage
        accentColor: CpuService.usage < 0.5 ? Theme.successColor
            : CpuService.usage < 0.8 ? Theme.accentColor : Theme.dangerColor
    }

    OverviewMovableResourceCard {
        id: gpuTemperatureCard

        overview: root

        targetX: cpuUsageCard.targetX
        targetY: cpuUsageCard.targetY + height + 12
        cardSize: root.resourceSize
        visible: CpuService.gpuAvailable
        label: "GPU TEMPERATURE"
        icon: Icons.temperature
        value: Math.round(CpuService.gpuTemperature) + "°C"
        detail: CpuService.gpuName
        progress: CpuService.gpuTemperature / 100
        accentColor: root.temperatureColor(CpuService.gpuTemperature)
    }

    OverviewMovableResourceCard {
        id: uvIndexCard

        overview: root

        targetX: root.usableArea.x
        targetY: root.usableArea.y + root.usableArea.height - height
        cardSize: root.environmentSize
        label: "UV INDEX"
        icon: Icons.ultraviolet
        value: WeatherService.environmentalAvailable
            ? WeatherService.uvIndex.toFixed(1) : "--"
        detail: ""
        progress: WeatherService.uvIndex / 11
        accentColor: root.uvColor(WeatherService.uvIndex)
    }

    OverviewMovableResourceCard {
        id: humidityCard

        overview: root

        targetX: uvIndexCard.targetX + width + 12
        targetY: uvIndexCard.targetY
        cardSize: root.environmentSize
        label: "HUMIDITY"
        icon: Icons.humidity
        value: WeatherService.environmentalAvailable
            ? Math.round(WeatherService.humidity) + "%" : "--%"
        detail: ""
        progress: WeatherService.humidity / 100
        accentColor: WeatherService.humidity < 70
            ? Theme.successColor : Theme.accentColor
    }

    OverviewMovableResourceCard {
        id: airQualityCard

        overview: root

        targetX: humidityCard.targetX + width + 12
        targetY: humidityCard.targetY
        cardSize: root.environmentSize
        visible: WeatherService.airQualityAvailable
        label: "AQI"
        icon: Icons.airQuality
        value: Math.round(WeatherService.airQualityIndex).toString()
        detail: ""
        progress: WeatherService.airQualityIndex / 300
        accentColor: root.airQualityColor(WeatherService.airQualityIndex)

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
    Connections {
        target: WeatherService
        function onAirQualityAvailableChanged(): void {
            root.schedulePlacement();
        }
    }
    onWidthChanged: schedulePlacement()
    onHeightChanged: schedulePlacement()
    Component.onCompleted: schedulePlacement()
}
