pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string homeDirectory: Quickshell.env("HOME") || ""
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME")
        || (homeDirectory + "/.config")

    readonly property var defaults: ({
        // Appearance
        uiScale: 1.0,
        cornerRadiusScale: 1.0,
        blurStrength: 1.0,
        surfaceOpacity: 0.94,
        reduceTransparency: false,

        // Colors
        theme: "dynamic",
        colorMode: "auto",
        manualAccentEnabled: false,
        manualAccentColor: "#89b4fa",
        dynamicSaturation: 1.0,
        dynamicContrast: 1.0,
        wallpaperUpdatesPalette: true,

        // Launcher
        launcherWidth: 620,
        launcherVisibleRows: 9,
        launcherShowDescriptions: false,
        launcherShowIcons: true,
        launcherRememberQuery: false,
        launcherCommandMode: true,
        launcherCommandSettings: true,
        launcherCommandColors: true,
        launcherCommandTmux: true,
        launcherCommandWallpapers: true,

        // Wallpaper
        wallpaperDirectory: "~/Pictures/Wallpapers",
        wallpaperTransitionType: "circle",
        wallpaperShuffle: false,
        wallpaperShuffleMinutes: 30,

        // Status bar
        statusBarPosition: "top",
        statusBarHeight: 40,
        statusBarAutoHide: false,
        statusBarShowLogo: true,
        statusBarShowWorkspaces: true,
        statusBarShowWorkspaceName: true,
        statusBarShowAudio: true,
        statusBarShowMedia: true,
        statusBarShowClock: true,
        statusBarShowBattery: true,
        statusBarShowMemory: true,
        statusBarShowTray: true,
        clock24Hour: false,
        clockShowSeconds: false,
        workspaceIndicatorStyle: "pill",

        // Behavior
        launcherCloseOnLaunch: true,
        launcherEscapeClearsQuery: true,
        clickOutsideDismiss: false,
        globalAnimationSpeed: 1.0,
        reduceMotion: false,

        // Floating widgets
        floatingWidgetVisibilityMode: "desktop",
        floatingWidgetScale: 1.0,
        floatingWidgetLockPlacement: false,
        floatingWidgetOpacity: 1.0,
        clockWidget: true,
        weatherWidget: true,
        calendarWidget: true,
        cpuTemperatureWidget: true,
        cpuUsageWidget: true,
        gpuTemperatureWidget: true,
        uvIndexWidget: true,
        humidityWidget: true,
        airQualityWidget: true,

        // Integrations
        terminalIntegration: false,
        gtkIntegration: false,
        spotifyIntegration: false,
        vesktopIntegration: false,
        btopIntegration: false,
        cavaIntegration: false,
        tmuxIntegration: false,

        // Per-group animation settings
        panelAnimation: "spring",
        panelDuration: 340,
        launcherAnimation: "spatial",
        launcherDuration: 240,
        contentAnimation: "spatial",
        contentDuration: 340,
        notificationAnimation: "spatial",
        notificationDuration: 340,
        wallpaperAnimation: "spatial",
        wallpaperDuration: 1200,
        statusBarAnimation: "spatial",
        statusBarDuration: 420,
        floatingWidgetAnimation: "spatial",
        floatingWidgetDuration: 650
    })

    // Appearance
    property real uiScale: defaults.uiScale
    property real cornerRadiusScale: defaults.cornerRadiusScale
    property real blurStrength: defaults.blurStrength
    property real surfaceOpacity: defaults.surfaceOpacity
    property bool reduceTransparency: defaults.reduceTransparency

    // Colors
    property string theme: defaults.theme
    property string colorMode: defaults.colorMode
    property bool manualAccentEnabled: defaults.manualAccentEnabled
    property string manualAccentColor: defaults.manualAccentColor
    property real dynamicSaturation: defaults.dynamicSaturation
    property real dynamicContrast: defaults.dynamicContrast
    property bool wallpaperUpdatesPalette: defaults.wallpaperUpdatesPalette

    // Launcher
    property int launcherWidth: defaults.launcherWidth
    property int launcherVisibleRows: defaults.launcherVisibleRows
    property bool launcherShowDescriptions: defaults.launcherShowDescriptions
    property bool launcherShowIcons: defaults.launcherShowIcons
    property bool launcherRememberQuery: defaults.launcherRememberQuery
    property bool launcherCommandMode: defaults.launcherCommandMode
    property bool launcherCommandSettings: defaults.launcherCommandSettings
    property bool launcherCommandColors: defaults.launcherCommandColors
    property bool launcherCommandTmux: defaults.launcherCommandTmux
    property bool launcherCommandWallpapers: defaults.launcherCommandWallpapers

    // Wallpaper
    property string wallpaperDirectory: defaults.wallpaperDirectory
    property string wallpaperTransitionType: defaults.wallpaperTransitionType
    property bool wallpaperShuffle: defaults.wallpaperShuffle
    property int wallpaperShuffleMinutes: defaults.wallpaperShuffleMinutes

    // Status bar
    property string statusBarPosition: defaults.statusBarPosition
    property int statusBarHeight: defaults.statusBarHeight
    property bool statusBarAutoHide: defaults.statusBarAutoHide
    property bool statusBarShowLogo: defaults.statusBarShowLogo
    property bool statusBarShowWorkspaces: defaults.statusBarShowWorkspaces
    property bool statusBarShowWorkspaceName: defaults.statusBarShowWorkspaceName
    property bool statusBarShowAudio: defaults.statusBarShowAudio
    property bool statusBarShowMedia: defaults.statusBarShowMedia
    property bool statusBarShowClock: defaults.statusBarShowClock
    property bool statusBarShowBattery: defaults.statusBarShowBattery
    property bool statusBarShowMemory: defaults.statusBarShowMemory
    property bool statusBarShowTray: defaults.statusBarShowTray
    property bool clock24Hour: defaults.clock24Hour
    property bool clockShowSeconds: defaults.clockShowSeconds
    property string workspaceIndicatorStyle: defaults.workspaceIndicatorStyle

    // Behavior
    property bool launcherCloseOnLaunch: defaults.launcherCloseOnLaunch
    property bool launcherEscapeClearsQuery: defaults.launcherEscapeClearsQuery
    property bool clickOutsideDismiss: defaults.clickOutsideDismiss
    property real globalAnimationSpeed: defaults.globalAnimationSpeed
    property bool reduceMotion: defaults.reduceMotion

    // Floating widgets
    property string floatingWidgetVisibilityMode: defaults.floatingWidgetVisibilityMode
    property real floatingWidgetScale: defaults.floatingWidgetScale
    property bool floatingWidgetLockPlacement: defaults.floatingWidgetLockPlacement
    property real floatingWidgetOpacity: defaults.floatingWidgetOpacity
    property bool clockWidget: defaults.clockWidget
    property bool weatherWidget: defaults.weatherWidget
    property bool calendarWidget: defaults.calendarWidget
    property bool cpuTemperatureWidget: defaults.cpuTemperatureWidget
    property bool cpuUsageWidget: defaults.cpuUsageWidget
    property bool gpuTemperatureWidget: defaults.gpuTemperatureWidget
    property bool uvIndexWidget: defaults.uvIndexWidget
    property bool humidityWidget: defaults.humidityWidget
    property bool airQualityWidget: defaults.airQualityWidget

    // Integrations
    property bool terminalIntegration: defaults.terminalIntegration
    property bool gtkIntegration: defaults.gtkIntegration
    property bool spotifyIntegration: defaults.spotifyIntegration
    property bool vesktopIntegration: defaults.vesktopIntegration
    property bool btopIntegration: defaults.btopIntegration
    property bool cavaIntegration: defaults.cavaIntegration
    property bool tmuxIntegration: defaults.tmuxIntegration

    // Animation groups
    property string panelAnimation: defaults.panelAnimation
    property int panelDuration: defaults.panelDuration
    property string launcherAnimation: defaults.launcherAnimation
    property int launcherDuration: defaults.launcherDuration
    property string contentAnimation: defaults.contentAnimation
    property int contentDuration: defaults.contentDuration
    property string notificationAnimation: defaults.notificationAnimation
    property int notificationDuration: defaults.notificationDuration
    property string wallpaperAnimation: defaults.wallpaperAnimation
    property int wallpaperDuration: defaults.wallpaperDuration
    property string statusBarAnimation: defaults.statusBarAnimation
    property int statusBarDuration: defaults.statusBarDuration
    property string floatingWidgetAnimation: defaults.floatingWidgetAnimation
    property int floatingWidgetDuration: defaults.floatingWidgetDuration

    property bool loading: true

    function clamp(value, minimum, maximum): real {
        return Math.max(minimum, Math.min(maximum, Number(value)));
    }

    function validChoice(value, choices): bool {
        return typeof value === "string" && choices.indexOf(value) !== -1;
    }

    function validStyle(value): bool {
        return validChoice(value, ["off", "fade", "spatial", "spring"]);
    }

    function normalize(key: string, value): var {
        switch (key) {
        case "uiScale": return clamp(value, 0.80, 1.30);
        case "cornerRadiusScale": return clamp(value, 0.50, 1.60);
        case "blurStrength": return clamp(value, 0, 1.0);
        case "surfaceOpacity": return clamp(value, 0.60, 1.0);
        case "dynamicSaturation": return clamp(value, 0.55, 1.45);
        case "dynamicContrast": return clamp(value, 0.75, 1.35);
        case "launcherWidth": return Math.round(clamp(value, 420, 900));
        case "launcherVisibleRows": return Math.round(clamp(value, 3, 14));
        case "wallpaperShuffleMinutes": return Math.round(clamp(value, 1, 1440));
        case "statusBarHeight": return Math.round(clamp(value, 32, 64));
        case "globalAnimationSpeed": return clamp(value, 0.50, 2.0);
        case "floatingWidgetScale": return clamp(value, 0.70, 1.35);
        case "floatingWidgetOpacity": return clamp(value, 0.35, 1.0);
        case "panelDuration":
        case "launcherDuration":
        case "contentDuration":
        case "notificationDuration":
        case "wallpaperDuration":
        case "statusBarDuration":
        case "floatingWidgetDuration":
            return Math.round(clamp(value, 0, 5000));
        case "theme":
            return validChoice(value, ["dynamic", "gruvbox", "catppuccin"])
                ? value : defaults.theme;
        case "colorMode":
            return validChoice(value, ["auto", "light", "dark"])
                ? value : defaults.colorMode;
        case "wallpaperTransitionType":
            return validChoice(value, ["circle", "fade", "instant"])
                ? value : defaults.wallpaperTransitionType;
        case "statusBarPosition":
            return validChoice(value, ["top", "bottom"])
                ? value : defaults.statusBarPosition;
        case "workspaceIndicatorStyle":
            return validChoice(value, ["pill", "dots", "numbers"])
                ? value : defaults.workspaceIndicatorStyle;
        case "floatingWidgetVisibilityMode":
            return validChoice(value, ["desktop", "always", "hidden"])
                ? value : defaults.floatingWidgetVisibilityMode;
        case "panelAnimation":
        case "launcherAnimation":
        case "contentAnimation":
        case "notificationAnimation":
        case "wallpaperAnimation":
        case "statusBarAnimation":
        case "floatingWidgetAnimation":
            return validStyle(value) ? value : defaults[key];
        case "wallpaperDirectory":
            return typeof value === "string" && value.trim().length > 0
                ? value.trim() : defaults.wallpaperDirectory;
        case "manualAccentColor":
            return validChoice(value, [
                "#89b4fa", "#f38ba8", "#fab387", "#a6e3a1",
                "#94e2d5", "#cba6f7", "#f5c2e7"
            ]) ? value : defaults.manualAccentColor;
        default:
            return value;
        }
    }

    function apply(data): void {
        if (!data || typeof data !== "object")
            return;

        const keys = Object.keys(defaults);
        for (const key of keys) {
            if (data[key] === undefined || root[key] === undefined)
                continue;

            const expectedType = typeof defaults[key];
            if (typeof data[key] !== expectedType)
                continue;

            root[key] = normalize(key, data[key]);
        }
    }

    function snapshot(): var {
        const data = {};
        const keys = Object.keys(defaults);
        for (const key of keys)
            data[key] = root[key];
        return data;
    }

    function save(): void {
        if (!loading)
            settingsFile.setText(JSON.stringify(snapshot(), null, 2) + "\n");
    }

    function setValue(key: string, value): void {
        if (root[key] === undefined)
            return;

        const nextValue = normalize(key, value);
        if (root[key] === nextValue)
            return;

        root[key] = nextValue;
        save();
    }

    function resetDefaults(): void {
        loading = true;
        const keys = Object.keys(defaults);
        for (const key of keys)
            root[key] = defaults[key];
        loading = false;
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
