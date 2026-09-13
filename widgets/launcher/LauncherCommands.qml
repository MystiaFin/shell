import QtQuick
import "../../components/theme"

QtObject {
    readonly property var items: [
        {
            key: "command:settings",
            type: "command",
            name: "Settings",
            command: "settings",
            icon: Icons.settings
        },
        {
            key: "command:color-scheme",
            type: "command",
            name: "Color scheme",
            command: "colorScheme",
            icon: Icons.colorScheme
        },
        {
            key: "command:tmux",
            type: "command",
            name: "Tmux sessions",
            command: "tmux",
            icon: Icons.terminal
        },
        {
            key: "command:wallpapers",
            type: "command",
            name: "Wallpapers",
            command: "wallpapers",
            icon: Icons.wallpaper
        }
    ]
}
