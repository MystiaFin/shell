import QtQuick
import ".."
import "../../../services"

Column {
    width: parent ? parent.width : 0
    spacing: 12

    SettingsPalettePreview {}

    SettingsGroup {
        SettingsChoiceRow {
            width: parent.width
            title: "Color scheme"
            detail: "Choose the palette family used by the shell"
            value: SettingsService.theme
            options: [
                { value: "dynamic", label: "Dynamic" },
                { value: "gruvbox", label: "Gruvbox" },
                { value: "catppuccin", label: "Catppuccin" }
            ]
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("theme", value)
        }
        SettingsChoiceRow {
            width: parent.width
            title: "Color mode"
            detail: "Let the wallpaper decide, or force light/dark dynamic colors"
            value: SettingsService.colorMode
            options: [
                { value: "auto", label: "Auto" },
                { value: "light", label: "Light" },
                { value: "dark", label: "Dark" }
            ]
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("colorMode", value)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Manual accent"
            detail: "Override the wallpaper-derived accent in the dynamic palette"
            checked: SettingsService.manualAccentEnabled
            showSeparator: true
            onToggleRequested: SettingsService.setValue("manualAccentEnabled", !checked)
        }
        SettingsChoiceRow {
            width: parent.width
            title: "Accent preset"
            detail: "Pick the manual accent used when the override is enabled"
            value: SettingsService.manualAccentColor
            options: [
                { value: "#89b4fa", label: "Blue" },
                { value: "#f38ba8", label: "Rose" },
                { value: "#fab387", label: "Peach" },
                { value: "#a6e3a1", label: "Green" },
                { value: "#94e2d5", label: "Teal" },
                { value: "#cba6f7", label: "Purple" },
                { value: "#f5c2e7", label: "Pink" }
            ]
            onValueRequested: value => SettingsService.setValue("manualAccentColor", value)
        }
    }

    SettingsGroup {
        SettingsSliderRow {
            width: parent.width
            title: "Saturation"
            detail: "Tune how colorful the generated dynamic palette feels"
            value: SettingsService.dynamicSaturation
            minimum: 0.55; maximum: 1.45; step: 0.05; decimals: 2; suffix: "×"
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("dynamicSaturation", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Contrast"
            detail: "Increase or soften tonal separation in the dynamic palette"
            value: SettingsService.dynamicContrast
            minimum: 0.75; maximum: 1.35; step: 0.05; decimals: 2; suffix: "×"
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("dynamicContrast", value)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Follow wallpaper colors"
            detail: "Regenerate the dynamic palette when the wallpaper changes"
            checked: SettingsService.wallpaperUpdatesPalette
            onToggleRequested: SettingsService.setValue("wallpaperUpdatesPalette", !checked)
        }
    }
}
