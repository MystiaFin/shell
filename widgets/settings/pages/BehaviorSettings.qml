import QtQuick
import ".."
import "../../../services"

Column {
    width: parent ? parent.width : 0
    spacing: 12

    SettingsGroup {
        SettingsToggleRow {
            width: parent.width
            title: "Close launcher after launch"
            detail: "Dismiss the launcher after starting an app, tmux session, or palette"
            checked: SettingsService.launcherCloseOnLaunch
            showSeparator: true
            onToggleRequested: SettingsService.setValue("launcherCloseOnLaunch", !checked)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Escape clears launcher first"
            detail: "Clear a non-empty query before Escape closes the launcher"
            checked: SettingsService.launcherEscapeClearsQuery
            showSeparator: true
            onToggleRequested: SettingsService.setValue("launcherEscapeClearsQuery", !checked)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Click outside to dismiss"
            detail: "Let clicks outside open edge panels close the current overlay"
            checked: SettingsService.clickOutsideDismiss
            onToggleRequested: SettingsService.setValue("clickOutsideDismiss", !checked)
        }
    }

    SettingsGroup {
        SettingsSliderRow {
            width: parent.width
            title: "Animation speed"
            detail: "Apply a global speed multiplier on top of per-group durations"
            value: SettingsService.globalAnimationSpeed
            minimum: 0.50; maximum: 2.0; step: 0.10; decimals: 1; suffix: "×"
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("globalAnimationSpeed", value)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Reduce motion"
            detail: "Disable shell motion while preserving state changes"
            checked: SettingsService.reduceMotion
            onToggleRequested: SettingsService.setValue("reduceMotion", !checked)
        }
    }
}
