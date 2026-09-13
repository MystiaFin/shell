pragma Singleton

import Quickshell
import QtQuick
import "../../services"
import "palettes"

Singleton {
    readonly property string currentTheme: SettingsService.theme

    readonly property QtObject catppuccin: Catppuccin {}
    readonly property QtObject gruvbox: Gruvbox {}
    readonly property QtObject dynamic: Dynamic {}

    readonly property var availableThemes: [
        { id: "dynamic", name: "Dynamic" },
        { id: "gruvbox", name: "Gruvbox" },
        { id: "catppuccin", name: "Catppuccin" }
    ]

    function setTheme(themeId: string): void {
        const exists = availableThemes.some(theme => theme.id === themeId);
        if (exists)
            SettingsService.setValue("theme", themeId);
    }

    function withOpacity(colorValue: color, opacityValue: real): color {
        return Qt.rgba(colorValue.r, colorValue.g, colorValue.b,
            Math.max(0, Math.min(1, opacityValue)));
    }

    readonly property bool dynamicActive: currentTheme === "dynamic"
    readonly property QtObject activeTheme: dynamicActive
        ? dynamic : currentTheme === "gruvbox" ? gruvbox : catppuccin
    readonly property real surfaceOpacity: SettingsService.reduceTransparency
        ? 1 : SettingsService.surfaceOpacity

    readonly property color liquidColor: activeTheme.foregroundColor
    readonly property color windowColor: activeTheme.windowColor
    readonly property color maskColor: activeTheme.maskColor
    readonly property color wallpaperFallbackColor: activeTheme.wallpaperFallbackColor

    readonly property color shellBackgroundColor: activeTheme.foregroundColor
    readonly property color shellShadowColor: "#50000000"
    readonly property color panelSurfaceColor: withOpacity(
        activeTheme.searchBackgroundColor, surfaceOpacity)
    readonly property color hoverSurfaceColor: activeTheme.itemHoverColor
    readonly property color surfaceBorderColor: activeTheme.searchBorderColor
    readonly property color selectedSurfaceColor: activeTheme.highlightColor
    readonly property color primaryTextColor: activeTheme.textColor
    readonly property color secondaryTextColor: activeTheme.secondaryTextColor
    readonly property color mutedTextColor: activeTheme.placeholderTextColor
    readonly property color accentColor: activeTheme.accentColor
    readonly property color accentHoverColor: activeTheme.accentHoverColor
    readonly property color accentTextColor: activeTheme.accentTextColor
    readonly property color successColor: activeTheme.successColor
    readonly property color dangerColor: activeTheme.dangerColor
    readonly property bool lightMode: dynamicActive && dynamic.lightMode

    function toggleColorMode(): void {
        if (!dynamicActive)
            return;

        const next = dynamic.lightMode ? "dark" : "light";
        SettingsService.setValue("colorMode", next);
    }
}
