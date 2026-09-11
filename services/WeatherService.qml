pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string homeDirectory: Quickshell.env("HOME")
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME")
        || homeDirectory + "/.config"
    property real latitude: NaN
    property real longitude: NaN
    property string locationName: ""
    property bool configured: Number.isFinite(latitude)
        && Number.isFinite(longitude)
    property bool loading: false
    property bool available: false
    property string errorMessage: configured ? "Weather unavailable" : "Set weather location"
    property real temperature: 0
    property real highTemperature: 0
    property real lowTemperature: 0
    property int weatherCode: -1
    property date lastUpdated: new Date(0)
    property string responseData: ""
    property string loadedConfig: ""
    readonly property string conditionText: conditionForCode(weatherCode)
    readonly property string conditionIcon: iconForCode(weatherCode)

    function loadConfiguration(): void {
        const text = locationFile.text().trim();
        if (text === loadedConfig)
            return;

        loadedConfig = text;
        try {
            const config = text ? JSON.parse(text) : {};
            const hasCoordinates = config.latitude !== null
                && config.latitude !== undefined
                && config.longitude !== null
                && config.longitude !== undefined;
            latitude = hasCoordinates ? Number(config.latitude) : NaN;
            longitude = hasCoordinates ? Number(config.longitude) : NaN;
            locationName = config.locationName || "Local weather";
            if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
                latitude = NaN;
                longitude = NaN;
                available = false;
                errorMessage = "Set weather location";
                return;
            }
            refresh();
        } catch (error) {
            latitude = NaN;
            longitude = NaN;
            available = false;
            errorMessage = "Invalid weather location";
            console.warn("Could not parse weather-location.json:", error);
        }
    }

    function refresh(): void {
        if (!configured || weatherRequest.running)
            return;

        responseData = "";
        loading = true;
        const url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + latitude
            + "&longitude=" + longitude
            + "&current=temperature_2m,weather_code"
            + "&daily=temperature_2m_max,temperature_2m_min"
            + "&temperature_unit=celsius&forecast_days=1&timezone=auto";
        weatherRequest.command = ["curl", "--fail", "--silent", "--show-error",
            "--max-time", "15", url];
        weatherRequest.running = true;
    }

    function applyResponse(): void {
        loading = false;
        try {
            const response = JSON.parse(responseData);
            temperature = Number(response.current.temperature_2m);
            weatherCode = Number(response.current.weather_code);
            highTemperature = Number(response.daily.temperature_2m_max[0]);
            lowTemperature = Number(response.daily.temperature_2m_min[0]);
            lastUpdated = new Date();
            available = true;
            errorMessage = "";
        } catch (error) {
            errorMessage = "Weather unavailable";
            console.warn("Could not parse Open-Meteo response:", error);
        }
    }

    function conditionForCode(code: int): string {
        if (code === 0) return "Clear";
        if (code === 1 || code === 2) return "Partly cloudy";
        if (code === 3) return "Overcast";
        if (code === 45 || code === 48) return "Fog";
        if (code >= 51 && code <= 67) return "Rain";
        if (code >= 71 && code <= 77) return "Snow";
        if (code >= 80 && code <= 82) return "Showers";
        if (code >= 85 && code <= 86) return "Snow showers";
        if (code >= 95) return "Thunderstorm";
        return "Weather";
    }

    function iconForCode(code: int): string {
        if (code === 0) return "weather-sunny";
        if (code <= 2) return "weather-partly-cloudy";
        if (code === 3) return "weather-cloudy";
        if (code === 45 || code === 48) return "weather-fog";
        if (code >= 71 && code <= 77) return "weather-snowy";
        if (code >= 85 && code <= 86) return "weather-snowy-heavy";
        if (code >= 95) return "weather-lightning-rainy";
        return "weather-rainy";
    }

    FileView {
        id: locationFile
        path: root.configHome + "/quickshell/weather-location.json"
        printErrors: false
        blockLoading: true
    }

    Process {
        id: weatherRequest
        stdout: SplitParser {
            onRead: data => root.responseData += data
        }
        onExited: root.applyResponse()
    }

    Timer {
        interval: 1800000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.loadConfiguration()
    }

    Component.onCompleted: loadConfiguration()
}
