import QtQuick
import ".."
import "../../../services"

Column {
    width: parent ? parent.width : 0
    spacing: 12

    SettingsGroup {
        SettingsChoiceRow {
            width: parent.width
            title: "Visibility"
            detail: "Show widgets only on an empty desktop, always, or never"
            value: SettingsService.floatingWidgetVisibilityMode
            options: [
                { value: "desktop", label: "Desktop only" },
                { value: "always", label: "Always" },
                { value: "hidden", label: "Hidden" }
            ]
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("floatingWidgetVisibilityMode", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Widget scale"
            detail: "Scale desktop cards while keeping automatic placement"
            value: SettingsService.floatingWidgetScale
            minimum: 0.70; maximum: 1.35; step: 0.05; decimals: 2; suffix: "×"
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("floatingWidgetScale", value)
        }
        SettingsSliderRow {
            width: parent.width
            title: "Opacity"
            detail: "Adjust the opacity of the complete desktop widget layer"
            value: SettingsService.floatingWidgetOpacity
            minimum: 0.35; maximum: 1.0; step: 0.05; decimals: 2
            showSeparator: true
            onValueRequested: value => SettingsService.setValue("floatingWidgetOpacity", value)
        }
        SettingsToggleRow {
            width: parent.width
            title: "Lock placement"
            detail: "Keep the current automatic placement instead of recomputing it"
            checked: SettingsService.floatingWidgetLockPlacement
            onToggleRequested: SettingsService.setValue("floatingWidgetLockPlacement", !checked)
        }
    }

    SettingsGroup {
        SettingsToggleRow { width: parent.width; title: "Clock"; detail: "Large desktop clock"; checked: SettingsService.clockWidget; showSeparator: true; onToggleRequested: SettingsService.setValue("clockWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "Weather"; detail: "Current weather summary"; checked: SettingsService.weatherWidget; showSeparator: true; onToggleRequested: SettingsService.setValue("weatherWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "Calendar"; detail: "Monthly calendar"; checked: SettingsService.calendarWidget; showSeparator: true; onToggleRequested: SettingsService.setValue("calendarWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "CPU temperature"; detail: "Processor thermal card"; checked: SettingsService.cpuTemperatureWidget; showSeparator: true; onToggleRequested: SettingsService.setValue("cpuTemperatureWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "CPU usage"; detail: "Processor utilization card"; checked: SettingsService.cpuUsageWidget; showSeparator: true; onToggleRequested: SettingsService.setValue("cpuUsageWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "GPU temperature"; detail: "Shown only when a supported GPU is available"; checked: SettingsService.gpuTemperatureWidget; showSeparator: true; onToggleRequested: SettingsService.setValue("gpuTemperatureWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "UV index"; detail: "Requires configured weather data"; checked: SettingsService.uvIndexWidget; showSeparator: true; onToggleRequested: SettingsService.setValue("uvIndexWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "Humidity"; detail: "Requires configured weather data"; checked: SettingsService.humidityWidget; showSeparator: true; onToggleRequested: SettingsService.setValue("humidityWidget", !checked) }
        SettingsToggleRow { width: parent.width; title: "Air quality"; detail: "Shown only when air-quality data is available"; checked: SettingsService.airQualityWidget; onToggleRequested: SettingsService.setValue("airQualityWidget", !checked) }
    }
}
