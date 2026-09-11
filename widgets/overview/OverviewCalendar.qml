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
    readonly property var weekdays: ["S", "M", "T", "W", "T", "F", "S"]

    OverviewCardBackground {
        anchors.fill: parent
        wallpaperSourceItem: parent.wallpaperSourceItem
        wallpaperRect: parent.wallpaperRect
    }

    Column {
        anchors {
            fill: parent
            margins: 18
        }
        spacing: 7

        Text {
            width: parent.width
            text: CalendarService.currentMonthYear
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 17
            font.weight: Font.Bold
            horizontalAlignment: root.contentAlignment
        }

        Grid {
            width: parent.width
            columns: 7
            rowSpacing: 2

            Repeater {
                model: root.weekdays

                delegate: Text {
                    required property string modelData
                    width: parent.width / 7
                    height: 20
                    text: modelData
                    color: Theme.mutedTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Repeater {
                model: CalendarService.currentDaysModel

                delegate: Item {
                    required property int dayNumber
                    required property bool currentMonth
                    required property bool today
                    width: parent.width / 7
                    height: 25

                    Rectangle {
                        anchors.centerIn: parent
                        width: 25
                        height: 25
                        radius: 12.5
                        visible: parent.today
                        color: Theme.accentColor
                    }

                    Text {
                        anchors.centerIn: parent
                        text: parent.dayNumber
                        color: parent.today ? Theme.accentTextColor
                            : parent.currentMonth ? Theme.primaryTextColor
                            : Theme.mutedTextColor
                        opacity: parent.currentMonth || parent.today ? 1 : 0.45
                        font.family: Typography.bodyFontFamily
                        font.pixelSize: 11
                        font.weight: parent.today ? Font.Bold : Font.Normal
                    }
                }
            }
        }
    }
}
