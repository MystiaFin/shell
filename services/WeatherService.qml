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
    property real humidity: 0
    property real uvIndex: 0
    property bool environmentalAvailable: false
    property real airQualityIndex: 0
    property bool airQualityAvailable: false
    property int weatherCode: -1
    property date lastUpdated: new Date(0)
    property string responseData: ""
    property string airQualityResponseData: ""
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
        if (!configured || weatherRequest.running || airQualityRequest.running)
            return;

        responseData = "";
        airQualityResponseData = "";
        loading = true;
        const url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + latitude
            + "&longitude=" + longitude
            + "&current=temperature_2m,weather_code,relative_humidity_2m"
            + "&daily=temperature_2m_max,temperature_2m_min,uv_index_max"
            + "&temperature_unit=celsius&forecast_days=1&timezone=auto";
        const airQualityUrl = "https://air-quality-api.open-meteo.com/v1/air-quality"
            + "?latitude=" + latitude + "&longitude=" + longitude
            + "&current=us_aqi&timezone=auto";
        weatherRequest.command = ["curl", "--fail", "--silent", "--show-error",
            "--max-time", "15", url];
        airQualityRequest.command = ["curl", "--fail", "--silent", "--show-error",
            "--max-time", "15", airQualityUrl];
        weatherRequest.running = true;
        airQualityRequest.running = true;
    }

    function applyResponse(): void {
        loading = false;
        try {
            const response = JSON.parse(responseData);
            temperature = Number(response.current.temperature_2m);
            weatherCode = Number(response.current.weather_code);
            highTemperature = Number(response.daily.temperature_2m_max[0]);
            lowTemperature = Number(response.daily.temperature_2m_min[0]);
            const humidityValue = response.current.relative_humidity_2m;
            const uvValue = response.daily.uv_index_max[0];
            humidity = Number(humidityValue);
            uvIndex = Number(uvValue);
            environmentalAvailable = humidityValue !== null && uvValue !== null
                && Number.isFinite(humidity) && Number.isFinite(uvIndex);
            lastUpdated = new Date();
            available = true;
            errorMessage = "";
        } catch (error) {
            errorMessage = "Weather unavailable";
            console.warn("Could not parse Open-Meteo response:", error);
        }
    }

    function applyAirQualityResponse(exitCode: int): void {
        if (exitCode !== 0) {
            airQualityAvailable = false;
            return;
        }
        try {
            const response = JSON.parse(airQualityResponseData);
            const rawValue = response.current.us_aqi;
            const value = Number(rawValue);
            airQualityAvailable = rawValue !== null && Number.isFinite(value);
            if (airQualityAvailable)
                airQualityIndex = value;
        } catch (error) {
            airQualityAvailable = false;
            console.warn("Could not parse Open-Meteo air-quality response:", error);
        }
    }

    function conditionForCode(code: int): string {
        if (code === 0) return "Clear sky";
        if (code === 1) return "Mainly clear";
        if (code === 2) return "Partly cloudy";
        if (code === 3) return "Cloudy";
        if (code === 45) return "Fog";
        if (code === 48) return "Rime fog";
        if (code === 51) return "Light drizzle";
        if (code === 53) return "Drizzle";
        if (code === 55) return "Heavy drizzle";
        if (code === 56 || code === 57) return "Freezing drizzle";
        if (code === 61) return "Light rain";
        if (code === 63) return "Rain";
        if (code === 65) return "Heavy rain";
        if (code === 66 || code === 67) return "Freezing rain";
        if (code === 71) return "Light snow";
        if (code === 73) return "Snow";
        if (code === 75) return "Heavy snow";
        if (code === 77) return "Snow grains";
        if (code === 80) return "Light showers";
        if (code === 81) return "Rain showers";
        if (code === 82) return "Heavy showers";
        if (code === 85 || code === 86) return "Snow showers";
        if (code === 95) return "Thunderstorm";
        if (code === 96 || code === 99) return "Thunderstorm with hail";
        return "Weather";
    }

    function iconForCode(code: int): string {
        if (code === 0) return "weather-sunny";
        if (code === 1 || code === 2) return "weather-partly-cloudy";
        if (code === 3) return "weather-cloudy";
        if (code === 45 || code === 48) return "weather-fog";
        if (code >= 51 && code <= 57) return "weather-pouring";
        if (code >= 61 && code <= 67) return "weather-rainy";
        if (code >= 71 && code <= 77) return "weather-snowy";
        if (code >= 80 && code <= 82) return "weather-pouring";
        if (code >= 85 && code <= 86) return "weather-snowy-heavy";
        if (code >= 95) return "weather-lightning-rainy";
        return "weather-cloudy";
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

    Process {
        id: airQualityRequest
        stdout: SplitParser {
            onRead: data => root.airQualityResponseData += data
        }
        onExited: (exitCode, exitStatus) => root.applyAirQualityResponse(exitCode)
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
