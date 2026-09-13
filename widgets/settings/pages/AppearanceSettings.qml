import QtQuick
import ".."
import "../../../services"

Column {
    width: parent ? parent.width : 0
    spacing: 12

    SettingsGroup {
        SettingsSliderRow {
            width: parent.width
            title: "UI scale"
            detail: "Scale the shell's shared spacing, radii, and major chrome"
            value: SettingsService.uiScale
            minimum: 0.80; maximum: 1.30; step: 0.05; decimals: 2; suffix: "×"
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("uiScale", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Roundedness"
            detail: "Adjust the corner radius used across shell surfaces"
            value: SettingsService.cornerRadiusScale
            minimum: 0.50; maximum: 1.60; step: 0.05; decimals: 2; suffix: "×"
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("cornerRadiusScale", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Blur strength"
            detail: "Control wallpaper blur behind overview and wallpaper surfaces"
            value: SettingsService.blurStrength
            minimum: 0; maximum: 1; step: 0.05; decimals: 2
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("blurStrength", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Surface opacity"
            detail: "Make shell surfaces more or less transparent"
            value: SettingsService.surfaceOpacity
            minimum: 0.60; maximum: 1; step: 0.02; decimals: 2
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("surfaceOpacity", value)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Reduce transparency"
            detail: "Force opaque surfaces and disable wallpaper blur"
            checked: SettingsService.reduceTransparency
            onToggleRequested: SettingsService.setValue("reduceTransparency", !checked)
        }
    }
}
