import "../../components/theme"
import "../../services"

StatusResourceIndicator {
    resourceValue: MemoryService.usage
    indicatorColor: MemoryService.usage < 0.5
        ? Theme.successColor
        : MemoryService.usage < 0.8
            ? Theme.accentColor
            : Theme.dangerColor
    iconText: Icons.memory
    iconFontFamily: Typography.materialIconFontFamily
    outputText: MemoryService.usedFormatted
}
