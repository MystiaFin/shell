pragma Singleton

import Quickshell
import QtQuick
import "themes"

Singleton {
    property string currentTheme: "catppuccin"

    readonly property QtObject catppuccin: Catppuccin {}
    readonly property QtObject gruvbox: Gruvbox {}
    readonly property QtObject activeTheme: currentTheme === "gruvbox"
        ? gruvbox
        : catppuccin

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
    readonly property color statusBarHighlightColor: "#e5c890"
    readonly property color statusBarTextColor: activeTheme.textColor
    readonly property color statusBarMutedColor: activeTheme.placeholderTextColor
    readonly property color statusBarBlueColor: "#89b4fa"
    readonly property color statusBarGreenColor: "#a6e3a1"
    readonly property color statusBarRedColor: "#f38ba8"
    readonly property color statusBarAccentColor: "#ef9f76"
}
