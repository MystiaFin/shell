import QtQuick
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property Item wallpaperSourceItem
    required property rect wallpaperRect
    readonly property int contentAlignment:
        wallpaperRect.x + wallpaperRect.width / 2
            < wallpaperSourceItem.width / 2
        ? Text.AlignLeft : Text.AlignRight

    OverviewCardBackground {
        anchors.fill: parent
        wallpaperSourceItem: parent.wallpaperSourceItem
        wallpaperRect: parent.wallpaperRect
    }

    Column {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 22
            rightMargin: 22
        }
        spacing: 2

        Text {
            width: parent.width
            text: WeatherService.available
                ? Math.round(WeatherService.temperature) + "°"
                : "--°"
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 44
            font.weight: Font.Bold
            horizontalAlignment: root.contentAlignment
        }

        Text {
            width: parent.width
            text: WeatherService.available
                ? WeatherService.conditionText
                : WeatherService.errorMessage
            color: Theme.secondaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 14
            font.weight: Font.Medium
            elide: Text.ElideRight
            horizontalAlignment: root.contentAlignment
        }

        Text {
            width: parent.width
            visible: WeatherService.available
            text: "H " + Math.round(WeatherService.highTemperature) + "°  L "
                + Math.round(WeatherService.lowTemperature) + "°"
            color: Theme.secondaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 13
            horizontalAlignment: root.contentAlignment
        }

        Text {
            width: parent.width
            visible: WeatherService.available
            text: WeatherService.locationName
            color: Theme.mutedTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 12
            elide: Text.ElideRight
            horizontalAlignment: root.contentAlignment
        }
    }
}
