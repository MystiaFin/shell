import QtQuick
import "../../components/theme"
import "../../services"

QtObject {
    readonly property var allItems: [
        {
            key: "command:settings",
            type: "command",
            name: "Settings",
            detail: "Open shell settings",
            command: "settings",
            icon: Icons.settings,
            enabled: SettingsService.launcherCommandSettings
        },
        {
            key: "command:color-scheme",
            type: "command",
            name: "Color scheme",
            detail: "Switch shell palette",
            command: "colorScheme",
            icon: Icons.colorScheme,
            enabled: SettingsService.launcherCommandColors
        },
        {
            key: "command:tmux",
            type: "command",
            name: "Tmux sessions",
            detail: "Attach to a tmux session",
            command: "tmux",
            icon: Icons.terminal,
            enabled: SettingsService.launcherCommandTmux
        },
        {
            key: "command:wallpapers",
            type: "command",
            name: "Wallpapers",
            detail: "Choose a wallpaper",
            command: "wallpapers",
            icon: Icons.wallpaper,
            enabled: SettingsService.launcherCommandWallpapers
        }
    ]

    readonly property var items: allItems.filter(item => item.enabled)
}
