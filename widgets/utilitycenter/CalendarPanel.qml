import QtQuick
import QtQuick.Layouts
import "../../components/theme"
import "../../services"

Rectangle {
    id: root

    radius: ShellMetrics.radiusLarge
    color: Theme.panelSurfaceColor
    clip: true

    function snapshotCurrentMonth(): void {
        outgoingDays.clear();
        for (let index = 0; index < CalendarService.daysModel.count; index++) {
            const day = CalendarService.daysModel.get(index);
            outgoingDays.append({
                dayNumber: day.dayNumber,
                currentMonth: day.currentMonth,
                today: day.today
            });
        }
    }

    function navigate(direction: int, action: var): void {
        if (monthSlide.running || pageViewport.width <= 0)
            return;

        snapshotCurrentMonth();
        outgoingPage.monthTitle = CalendarService.monthYear;
        outgoingPage.x = 0;
        outgoingPage.visible = true;
        livePage.x = direction * pageViewport.width;
        action();
        monthSlide.direction = direction;
        monthSlide.start();
    }

    function resetMonth(): void {
        const displayed = CalendarService.displayedMonth;
        const today = CalendarService.today;
        const displayedIndex = displayed.getFullYear() * 12 + displayed.getMonth();
        const todayIndex = today.getFullYear() * 12 + today.getMonth();

        if (displayedIndex === todayIndex)
            return;
        navigate(todayIndex > displayedIndex ? 1 : -1,
            () => CalendarService.reset());
    }

    component MonthPage: ColumnLayout {
        id: page

        required property string monthTitle
        required property var daysModel
        property bool interactive: false

        signal resetRequested()

        spacing: 7

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            Layout.rightMargin: 68
            text: page.monthTitle
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 15
            font.weight: Font.DemiBold
            verticalAlignment: Text.AlignVCenter

            HoverHandler {
                enabled: page.interactive
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                enabled: page.interactive
                onTapped: page.resetRequested()
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
                    color: Theme.mutedTextColor
                    font.family: Typography.bodyFontFamily
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
                model: page.daysModel

                Rectangle {
                    required property int dayNumber
                    required property bool currentMonth
                    required property bool today

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: ShellMetrics.radiusSmall
                    color: today
                        ? Theme.accentColor
                        : dayHover.hovered && currentMonth
                            ? Theme.selectedSurfaceColor : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: dayNumber
                        color: today
                            ? Theme.accentTextColor
                            : currentMonth
                                ? Theme.primaryTextColor
                                : Theme.surfaceBorderColor
                        font.family: Typography.bodyFontFamily
                        font.pixelSize: 10
                        font.weight: today ? Font.DemiBold : Font.Light
                    }

                    HoverHandler {
                        id: dayHover
                        enabled: page.interactive
                    }
                }
            }
        }
    }

    Item {
        id: pageViewport

        anchors {
            fill: parent
            margins: 12
        }
        clip: true

        MonthPage {
            id: outgoingPage

            width: pageViewport.width
            height: pageViewport.height
            visible: false
            monthTitle: ""
            daysModel: outgoingDays
        }

        MonthPage {
            id: livePage

            width: pageViewport.width
            height: pageViewport.height
            monthTitle: CalendarService.monthYear
            daysModel: CalendarService.daysModel
            interactive: !monthSlide.running
            onResetRequested: root.resetMonth()
        }
    }

    Row {
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 12
            rightMargin: 12
        }
        spacing: 6

        Repeater {
            model: [
                {
                    icon: Icons.previousMonth,
                    direction: -1,
                    action: () => CalendarService.previousMonth()
                },
                {
                    icon: Icons.nextMonth,
                    direction: 1,
                    action: () => CalendarService.nextMonth()
                }
            ]

            Rectangle {
                required property var modelData

                width: 28
                height: 28
                radius: ShellMetrics.radiusSmall
                color: navHover.hovered
                    ? Theme.surfaceBorderColor
                    : Theme.selectedSurfaceColor

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    color: Theme.primaryTextColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 14
                }

                HoverHandler {
                    id: navHover
                    enabled: !monthSlide.running
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    enabled: !monthSlide.running
                    onTapped: root.navigate(modelData.direction, modelData.action)
                }
            }
        }
    }

    ListModel { id: outgoingDays }

    ParallelAnimation {
        id: monthSlide

        property int direction: 1

        NumberAnimation {
            target: outgoingPage
            property: "x"
            to: -monthSlide.direction * pageViewport.width
            duration: ShellMetrics.pageTransitionDurationMs
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: livePage
            property: "x"
            to: 0
            duration: ShellMetrics.pageTransitionDurationMs
            easing.type: Easing.OutCubic
        }

        onFinished: {
            outgoingPage.visible = false;
            outgoingDays.clear();
        }
    }
}
