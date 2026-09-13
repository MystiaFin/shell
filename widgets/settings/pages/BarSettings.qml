import QtQuick
import ".."
import "../../../services"

Column {
    width: parent ? parent.width : 0
    spacing: 12

    SettingsGroup {
        SettingsChoiceRow {
            width: parent.width
            title: "Position"
            detail: "Place the status bar on the top or bottom edge"
            value: SettingsService.statusBarPosition
            options: [
                { value: "top", label: "Top" },
                { value: "bottom", label: "Bottom" }
            ]
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("statusBarPosition", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Height"
            detail: "Adjust status bar height without changing its content scale"
            value: SettingsService.statusBarHeight
            minimum: 32; maximum: 64; step: 2; decimals: 0; suffix: " px"
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("statusBarHeight", value)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Auto-hide"
            detail: "Collapse to a thin screen-edge trigger when the pointer leaves"
            checked: SettingsService.statusBarAutoHide
            showSeparator: true
            onToggleRequested: SettingsService.setValue("statusBarAutoHide", !checked)
        }
        SettingsChoiceRow {
            width: parent.width
            title: "Workspace indicator"
            detail: "Choose the workspace strip presentation"
            value: SettingsService.workspaceIndicatorStyle
            options: [
                { value: "pill", label: "Pill" },
                { value: "dots", label: "Dots" },
                { value: "numbers", label: "Numbers" }
            ]
            onValueRequested: value => SettingsService.setValue("workspaceIndicatorStyle", value)
        }
    }

    SettingsGroup {
        SettingsToggleRow { width: parent.width; title: "NixOS logo"; detail: "Show the power-menu launcher"; checked: SettingsService.statusBarShowLogo; showSeparator: true; onToggleRequested: SettingsService.setValue("statusBarShowLogo", !checked) }
        SettingsToggleRow { width: parent.width; title: "Workspaces"; detail: "Show the workspace indicator"; checked: SettingsService.statusBarShowWorkspaces; showSeparator: true; onToggleRequested: SettingsService.setValue("statusBarShowWorkspaces", !checked) }
        SettingsToggleRow { width: parent.width; title: "Workspace name"; detail: "Show the active workspace label"; checked: SettingsService.statusBarShowWorkspaceName; showSeparator: true; onToggleRequested: SettingsService.setValue("statusBarShowWorkspaceName", !checked) }
        SettingsToggleRow { width: parent.width; title: "Audio controls"; detail: "Show output and microphone rings"; checked: SettingsService.statusBarShowAudio; showSeparator: true; onToggleRequested: SettingsService.setValue("statusBarShowAudio", !checked) }
        SettingsToggleRow { width: parent.width; title: "Media"; detail: "Show current media information"; checked: SettingsService.statusBarShowMedia; showSeparator: true; onToggleRequested: SettingsService.setValue("statusBarShowMedia", !checked) }
        SettingsToggleRow { width: parent.width; title: "Clock and date"; detail: "Show time and date in the center section"; checked: SettingsService.statusBarShowClock; showSeparator: true; onToggleRequested: SettingsService.setValue("statusBarShowClock", !checked) }
        SettingsToggleRow { width: parent.width; title: "Battery"; detail: "Show battery status"; checked: SettingsService.statusBarShowBattery; showSeparator: true; onToggleRequested: SettingsService.setValue("statusBarShowBattery", !checked) }
        SettingsToggleRow { width: parent.width; title: "Memory"; detail: "Show memory usage"; checked: SettingsService.statusBarShowMemory; showSeparator: true; onToggleRequested: SettingsService.setValue("statusBarShowMemory", !checked) }
        SettingsToggleRow { width: parent.width; title: "System tray group"; detail: "Show notifications, network, and Bluetooth shortcuts"; checked: SettingsService.statusBarShowTray; onToggleRequested: SettingsService.setValue("statusBarShowTray", !checked) }
    }

    SettingsGroup {
        SettingsToggleRow {
            width: parent.width
            title: "24-hour clock"
            detail: "Use 24-hour time instead of AM/PM"
            checked: SettingsService.clock24Hour
            showSeparator: true
            onToggleRequested: SettingsService.setValue("clock24Hour", !checked)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Show seconds"
            detail: "Include seconds in the status-bar clock"
            checked: SettingsService.clockShowSeconds
            onToggleRequested: SettingsService.setValue("clockShowSeconds", !checked)
        }
    }
}
