import QtQuick
import ".."
import "../../../services"

Column {
    id: root
    width: parent ? parent.width : 0
    spacing: 12

    signal resetRequested

    SettingsGroup {
        SettingsActionRow {
            width: parent.width
            title: "Quickshell"
            detail: DebugInfoService.quickshellVersion
            actionLabel: "Reload"
            showSeparator: true
            onActionRequested: DebugInfoService.reloadShell()
        }
        SettingsActionRow {
            width: parent.width
            title: "Config checkout"
            detail: "Git commit " + DebugInfoService.gitCommit
            actionLabel: "Open folder"
            showSeparator: true
            onActionRequested: DebugInfoService.openConfigDirectory()
        }
        SettingsActionRow {
            width: parent.width
            title: "Reset settings"
            detail: "Restore every setting in settings.json to its built-in default"
            actionLabel: "Reset"
            danger: true
            onActionRequested: root.resetRequested()
        }
    }
}
