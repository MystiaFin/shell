import QtQuick
import ".."
import "../../../services"

Column {
    id: root
    width: parent ? parent.width : 0
    spacing: 12

    signal integrationRequested(string name, string title, string warning)

    readonly property var integrationSettings: [
        { key: "gtk", title: "GTK", detail: "GTK 3/4 and desktop preferences", warning: "This writes generated GTK themes, changes gtk-theme, icon-theme and color-scheme through dconf, replaces ~/.config/gtk-4.0/gtk.css with a symlink, and restarts xdg-desktop-portal-gnome." },
        { key: "terminal", title: "Terminals", detail: "Kitty and foot", warning: "This overwrites Quickshell kitty and foot palette files, reloads kitty windows, signals all running foot processes, and writes color escape sequences to matching terminal TTYs." },
        { key: "tmux", title: "tmux", detail: "Status line and pane colors", warning: "This overwrites tmux-colors.conf and asks running tmux servers to source that file." },
        { key: "vesktop", title: "Vesktop", detail: "Vencord Quick CSS", warning: "This edits ~/.config/vesktop/settings/quickCss.css. Content outside the managed quickshell-theme marker is preserved, but the file itself is rewritten." },
        { key: "spotify", title: "Spotify", detail: "Spicetify color stylesheet", warning: "This creates and overwrites the Quickshell Spotify stylesheet under your cache directory." },
        { key: "btop", title: "btop", detail: "Generated terminal monitor theme", warning: "This creates and overwrites ~/.config/btop/themes/quickshell.theme." },
        { key: "cava", title: "Cava", detail: "Generated visualizer theme", warning: "This creates and overwrites ~/.config/cava/themes/quickshell." }
    ]

    SettingsGroup {
        Repeater {
            model: root.integrationSettings
            delegate: SettingsToggleRow {
                required property var modelData
                required property int index
                width: root.width
                title: modelData.title
                detail: modelData.detail
                checked: SettingsService[modelData.key + "Integration"]
                showSeparator: index < root.integrationSettings.length - 1
                onToggleRequested: {
                    const settingKey = modelData.key + "Integration";
                    if (SettingsService[settingKey])
                        SettingsService.setValue(settingKey, false);
                    else
                        root.integrationRequested(modelData.key, modelData.title, modelData.warning);
                }
            }
        }
    }
}
