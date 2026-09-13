import QtQuick
import ".."
import "../../../services"

Column {
    width: parent ? parent.width : 0
    spacing: 12

    SettingsGroup {
        SettingsSliderRow {
            width: parent.width
            title: "Launcher width"
            detail: "Set the preferred launcher panel width"
            value: SettingsService.launcherWidth
            minimum: 420; maximum: 900; step: 20; decimals: 0; suffix: " px"
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("launcherWidth", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Visible results"
            detail: "Limit how many rows are shown before the list scrolls"
            value: SettingsService.launcherVisibleRows
            minimum: 3; maximum: 14; step: 1; decimals: 0
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("launcherVisibleRows", value)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Application descriptions"
            detail: "Show generic names or application comments below results"
            checked: SettingsService.launcherShowDescriptions
            showSeparator: true
            onToggleRequested: SettingsService.setValue("launcherShowDescriptions", !checked)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Result icons"
            detail: "Show application and command icons"
            checked: SettingsService.launcherShowIcons
            showSeparator: true
            onToggleRequested: SettingsService.setValue("launcherShowIcons", !checked)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Remember query"
            detail: "Keep the last search when the launcher is reopened normally"
            checked: SettingsService.launcherRememberQuery
            onToggleRequested: SettingsService.setValue("launcherRememberQuery", !checked)
        }
    }

    SettingsGroup {
        SettingsToggleRow {
            width: parent.width
            title: "Command mode"
            detail: "Enable the > command palette prefix"
            checked: SettingsService.launcherCommandMode
            showSeparator: true
            onToggleRequested: SettingsService.setValue("launcherCommandMode", !checked)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Settings command"
            detail: "Show Settings in command mode"
            checked: SettingsService.launcherCommandSettings
            showSeparator: true
            onToggleRequested: SettingsService.setValue("launcherCommandSettings", !checked)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Color scheme command"
            detail: "Show Color scheme in command mode"
            checked: SettingsService.launcherCommandColors
            showSeparator: true
            onToggleRequested: SettingsService.setValue("launcherCommandColors", !checked)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Tmux command"
            detail: "Show Tmux sessions in command mode"
            checked: SettingsService.launcherCommandTmux
            showSeparator: true
            onToggleRequested: SettingsService.setValue("launcherCommandTmux", !checked)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Wallpaper command"
            detail: "Show Wallpapers in command mode"
            checked: SettingsService.launcherCommandWallpapers
            onToggleRequested: SettingsService.setValue("launcherCommandWallpapers", !checked)
        }
    }
}
