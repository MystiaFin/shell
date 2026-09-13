pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")

    property bool terminalIntegration: false
    property bool gtkIntegration: false
    property bool spotifyIntegration: false
    property bool vesktopIntegration: false
    property bool btopIntegration: false
    property bool cavaIntegration: false
    property bool tmuxIntegration: false

    property bool clockWidget: true
    property bool weatherWidget: true
    property bool calendarWidget: true
    property bool cpuTemperatureWidget: true
    property bool cpuUsageWidget: true
    property bool gpuTemperatureWidget: true
    property bool uvIndexWidget: true
    property bool humidityWidget: true
    property bool airQualityWidget: true

    property string panelAnimation: "spring"
    property int panelDuration: 340
    property string launcherAnimation: "spatial"
    property int launcherDuration: 240
    property string contentAnimation: "spatial"
    property int contentDuration: 340
    property string notificationAnimation: "spatial"
    property int notificationDuration: 340
    property string wallpaperAnimation: "spatial"
    property int wallpaperDuration: 1200
    property string statusBarAnimation: "spatial"
    property int statusBarDuration: 420
    property string floatingWidgetAnimation: "spatial"
    property int floatingWidgetDuration: 650

    property bool loading: true

    function validStyle(value): bool {
        return ["off", "fade", "spatial", "spring"].indexOf(value) !== -1;
    }

    function apply(data): void {
        if (!data || typeof data !== "object")
            return;

        const booleanKeys = [
            "terminalIntegration", "gtkIntegration", "spotifyIntegration",
            "vesktopIntegration", "btopIntegration", "cavaIntegration",
            "tmuxIntegration", "clockWidget", "weatherWidget",
            "calendarWidget", "cpuTemperatureWidget", "cpuUsageWidget",
            "gpuTemperatureWidget", "uvIndexWidget", "humidityWidget",
            "airQualityWidget"
        ];
        for (const key of booleanKeys) {
            if (typeof data[key] === "boolean")
                root[key] = data[key];
        }

        const groups = ["panel", "launcher", "content", "notification",
            "wallpaper", "statusBar", "floatingWidget"];
        for (const group of groups) {
            const styleKey = group + "Animation";
            const durationKey = group + "Duration";
            if (root.validStyle(data[styleKey]))
                root[styleKey] = data[styleKey];
            if (typeof data[durationKey] === "number")
                root[durationKey] = Math.max(0, Math.min(5000, Math.round(data[durationKey])));
        }
    }

    function snapshot(): var {
        return {
            terminalIntegration, gtkIntegration, spotifyIntegration,
            vesktopIntegration, btopIntegration, cavaIntegration,
            tmuxIntegration, clockWidget, weatherWidget, calendarWidget,
            cpuTemperatureWidget, cpuUsageWidget, gpuTemperatureWidget,
            uvIndexWidget, humidityWidget, airQualityWidget,
            panelAnimation, panelDuration, launcherAnimation, launcherDuration,
            contentAnimation, contentDuration, notificationAnimation,
            notificationDuration, wallpaperAnimation, wallpaperDuration,
            statusBarAnimation, statusBarDuration, floatingWidgetAnimation,
            floatingWidgetDuration
        };
    }

    function save(): void {
        if (!loading)
            settingsFile.setText(JSON.stringify(snapshot(), null, 2) + "\n");
    }

    function setValue(key: string, value): void {
        if (root[key] === undefined || root[key] === value)
            return;
        root[key] = value;
        save();
    }

    function integrationEnabled(name: string): bool {
        return root[name + "Integration"] === true;
    }

    function anyFloatingWidgetEnabled(): bool {
        return clockWidget || weatherWidget || calendarWidget
            || cpuTemperatureWidget || cpuUsageWidget || gpuTemperatureWidget
            || uvIndexWidget || humidityWidget || airQualityWidget;
    }

    FileView {
        id: settingsFile
        path: root.configHome + "/quickshell/settings.json"
        atomicWrites: true
        blockLoading: true
        printErrors: false
    }

    Component.onCompleted: {
        try {
            const text = settingsFile.text();
            if (text.trim())
                apply(JSON.parse(text));
        } catch (error) {
            console.warn("Could not load Quickshell settings:", error);
        }
        loading = false;
    }
}
