pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property date displayedMonth: new Date()
    property date today: new Date()
    property alias daysModel: calendarDaysModel
    property alias currentDaysModel: currentCalendarDaysModel
    readonly property string monthYear: Qt.formatDate(displayedMonth, "MMMM yyyy")
    readonly property string currentMonthYear: Qt.formatDate(today, "MMMM yyyy")

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
        populateMonth(calendarDaysModel, displayedMonth);
    }

    function rebuildCurrentMonth(): void {
        populateMonth(currentCalendarDaysModel, today);
    }

    function populateMonth(model: ListModel, monthDate: date): void {
        const year = monthDate.getFullYear();
        const month = monthDate.getMonth();
        const firstWeekday = new Date(year, month, 1).getDay();
        const previousMonthDays = new Date(year, month, 0).getDate();
        const currentMonthDays = new Date(year, month + 1, 0).getDate();
        const todayDay = today.getDate();
        const todayMonth = today.getMonth();
        const todayYear = today.getFullYear();

        model.clear();
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

            model.append({
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
    ListModel { id: currentCalendarDaysModel }

    Timer {
        id: dayChangeTimer
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            const now = new Date();
            if (now.getDate() !== root.today.getDate()
                    || now.getMonth() !== root.today.getMonth()
                    || now.getFullYear() !== root.today.getFullYear()) {
                root.today = now;
                root.rebuild();
                root.rebuildCurrentMonth();
            }
        }
    }

    Component.onCompleted: {
        rebuild();
        rebuildCurrentMonth();
    }
}
