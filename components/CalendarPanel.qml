import QtQuick
import QtQuick.Layouts
import "../services"

Rectangle {
    id: root

    radius: 16
    color: Theme.statusBarSurfaceColor
    clip: true

    ColumnLayout {
        anchors {
            fill: parent
            margins: 12
        }
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28

            Text {
                Layout.fillWidth: true
                text: CalendarService.monthYear
                color: Theme.statusBarTextColor
                font.family: "Poppins"
                font.pixelSize: 15
                font.weight: Font.DemiBold

                HoverHandler { cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: CalendarService.reset() }
            }

            Repeater {
                model: [
                    { icon: "󰁍", action: () => CalendarService.previousMonth() },
                    { icon: "󰁔", action: () => CalendarService.nextMonth() }
                ]

                Rectangle {
                    required property var modelData

                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 9
                    color: navHover.hovered
                        ? Theme.statusBarSurfaceBorderColor
                        : Theme.statusBarWorkspaceColor

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        color: Theme.statusBarTextColor
                        font.family: "JetBrains Mono Nerd Font"
                        font.pixelSize: 14
                    }

                    HoverHandler {
                        id: navHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler { onTapped: modelData.action() }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 18
            columns: 7
            columnSpacing: 0

            Repeater {
                model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

                Text {
                    required property string modelData

                    Layout.fillWidth: true
                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.statusBarMutedColor
                    font.family: "Poppins"
                    font.pixelSize: 9
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 7
            rows: 6
            columnSpacing: 2
            rowSpacing: 2

            Repeater {
                model: CalendarService.model

                Rectangle {
                    required property int day
                    required property bool currentMonth
                    required property bool today

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    color: today
                        ? Theme.statusBarBlueColor
                        : dayHover.hovered && currentMonth
                            ? Theme.statusBarWorkspaceColor : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: day
                        color: today
                            ? Theme.statusBarBackgroundColor
                            : currentMonth
                                ? Theme.statusBarTextColor
                                : Theme.statusBarSurfaceBorderColor
                        font.family: "Poppins"
                        font.pixelSize: 10
                        font.weight: today ? Font.DemiBold : Font.Light
                    }

                    HoverHandler { id: dayHover }
                }
            }
        }
    }
}
