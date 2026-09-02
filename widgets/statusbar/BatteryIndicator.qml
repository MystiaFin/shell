import "../../components/theme"
import "../../services"

StatusResourceIndicator {
    resourceAvailable: BatteryService.available
    resourceValue: BatteryService.level
    indicatorColor: BatteryService.charging
        ? Theme.successColor
        : BatteryService.percent > 20
            ? Theme.accentColor
            : Theme.dangerColor
    iconText: BatteryService.icon
    iconFontFamily: Typography.materialIconFontFamily
    outputText: BatteryService.percent + "%"
}
