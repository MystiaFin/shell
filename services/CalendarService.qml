pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property date displayedMonth: new Date()
    property date today: new Date()
    property alias daysModel: calendarDaysModel
    readonly property string monthYear: Qt.formatDate(displayedMonth, "MMMM yyyy")

    function previousMonth(): void {
        displayedMonth = new Date(displayedMonth.getFullYear(), displayedMonth.getMonth() - 1, 1);
        rebuild();
    }

    function nextMonth(): void {
        displayedMonth = new Date(displayedMonth.getFullYear(), displayedMonth.getMonth() + 1, 1);
        rebuild();
    }

    function reset(): void {
        displayedMonth = new Date();
        rebuild();
    }

    function rebuild(): void {
        const year = displayedMonth.getFullYear();
        const month = displayedMonth.getMonth();
        const firstWeekday = new Date(year, month, 1).getDay();
        const previousMonthDays = new Date(year, month, 0).getDate();
        const currentMonthDays = new Date(year, month + 1, 0).getDate();
        const todayDay = today.getDate();
        const todayMonth = today.getMonth();
        const todayYear = today.getFullYear();

        calendarDaysModel.clear();
        for (let cellIndex = 0; cellIndex < 42; cellIndex++) {
            const dayOffset = cellIndex - firstWeekday + 1;
            let dayNumber = dayOffset;
            let relativeMonth = 0;
            if (dayOffset <= 0) {
                dayNumber = previousMonthDays + dayOffset;
                relativeMonth = -1;
            } else if (dayOffset > currentMonthDays) {
                dayNumber = dayOffset - currentMonthDays;
                relativeMonth = 1;
            }

            calendarDaysModel.append({
                dayNumber: dayNumber,
                currentMonth: relativeMonth === 0,
                today: relativeMonth === 0
                    && dayNumber === todayDay
                    && month === todayMonth
                    && year === todayYear
            });
        }
    }

    ListModel { id: calendarDaysModel }

    Timer {
        id: dayChangeTimer
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            const now = new Date();
            if (now.getDate() !== root.today.getDate()) {
                root.today = now;
                root.rebuild();
            }
        }
    }

    Component.onCompleted: rebuild()
}
