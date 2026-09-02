pragma Singleton

import Quickshell
import QtQuick
import "palettes"

Singleton {
    property string currentTheme: "dynamic"

    readonly property QtObject catppuccin: Catppuccin {}
    readonly property QtObject gruvbox: Gruvbox {}
    readonly property QtObject dynamic: Dynamic {}
    readonly property bool dynamicActive: currentTheme === "dynamic"
    readonly property QtObject activeTheme: dynamicActive
        ? dynamic
        : currentTheme === "gruvbox" ? gruvbox : catppuccin

    readonly property color liquidColor: activeTheme.foregroundColor
    readonly property color windowColor: activeTheme.windowColor
    readonly property color maskColor: activeTheme.maskColor
    readonly property color wallpaperFallbackColor: activeTheme.wallpaperFallbackColor

    readonly property color shellBackgroundColor: activeTheme.foregroundColor
    readonly property color panelSurfaceColor: activeTheme.searchBackgroundColor
    readonly property color surfaceBorderColor: activeTheme.searchBorderColor
    readonly property color selectedSurfaceColor: activeTheme.highlightColor
    readonly property color primaryTextColor: activeTheme.textColor
    readonly property color secondaryTextColor: activeTheme.secondaryTextColor
    readonly property color mutedTextColor: activeTheme.placeholderTextColor
    readonly property color accentColor: activeTheme.accentColor
    readonly property color accentHoverColor: activeTheme.accentHoverColor
    readonly property color successColor: activeTheme.successColor
    readonly property color dangerColor: activeTheme.dangerColor
}
