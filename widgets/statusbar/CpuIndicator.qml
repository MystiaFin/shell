import "../../components/theme"
import "../../services"

StatusResourceIndicator {
    resourceValue: CpuService.usage
    indicatorColor: CpuService.usage < 0.5
        ? Theme.successColor
        : CpuService.usage < 0.8
            ? Theme.accentColor
            : Theme.dangerColor
    iconText: Icons.cpu
    iconFontFamily: Typography.nerdIconFontFamily
    outputText: CpuService.percent + "%"
}
