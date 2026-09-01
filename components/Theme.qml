pragma Singleton

import Quickshell
import QtQuick
import "themes"

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
    readonly property color launcherTextColor: activeTheme.textColor
    readonly property color launcherSecondaryTextColor: activeTheme.secondaryTextColor
    readonly property color launcherItemHoverColor: activeTheme.itemHoverColor
    readonly property color launcherSelectionColor: activeTheme.highlightColor
    readonly property color launcherSearchBackgroundColor: activeTheme.searchBackgroundColor
    readonly property color launcherSearchBorderColor: activeTheme.searchBorderColor
    readonly property color launcherPlaceholderTextColor: activeTheme.placeholderTextColor
    readonly property color wallpaperFallbackColor: activeTheme.wallpaperFallbackColor
    readonly property color statusBarBackgroundColor: activeTheme.foregroundColor
    readonly property color statusBarSurfaceColor: activeTheme.searchBackgroundColor
    readonly property color statusBarSurfaceBorderColor: activeTheme.searchBorderColor
    readonly property color statusBarWorkspaceColor: activeTheme.highlightColor
    readonly property color statusBarHighlightColor: dynamicActive
        ? dynamic.highlightAccentColor : "#e5c890"
    readonly property color statusBarTextColor: activeTheme.textColor
    readonly property color statusBarMutedColor: activeTheme.placeholderTextColor
    readonly property color statusBarBlueColor: dynamicActive
        ? dynamic.blueColor : "#89b4fa"
    readonly property color statusBarGreenColor: dynamicActive
        ? dynamic.greenColor : "#a6e3a1"
    readonly property color statusBarRedColor: dynamicActive
        ? dynamic.redColor : "#f38ba8"
    readonly property color statusBarAccentColor: dynamicActive
        ? dynamic.accentColor : "#ef9f76"
}
