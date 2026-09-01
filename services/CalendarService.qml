pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property date displayDate: new Date()
    property date today: new Date()
    property alias model: days
    readonly property string monthYear: Qt.formatDate(displayDate, "MMMM yyyy")

    function previousMonth(): void {
        displayDate = new Date(displayDate.getFullYear(), displayDate.getMonth() - 1, 1);
        rebuild();
    }

    function nextMonth(): void {
        displayDate = new Date(displayDate.getFullYear(), displayDate.getMonth() + 1, 1);
        rebuild();
    }

    function reset(): void {
        displayDate = new Date();
        rebuild();
    }

    function rebuild(): void {
        const year = displayDate.getFullYear();
        const month = displayDate.getMonth();
        const firstWeekday = new Date(year, month, 1).getDay();
        const previousMonthDays = new Date(year, month, 0).getDate();

        days.clear();
        for (let cell = 0; cell < 42; cell++) {
            const offset = cell - firstWeekday + 1;
            let day = offset;
            let relativeMonth = 0;
            if (offset <= 0) {
                day = previousMonthDays + offset;
                relativeMonth = -1;
            } else {
                const currentMonthDays = new Date(year, month + 1, 0).getDate();
                if (offset > currentMonthDays) {
                    day = offset - currentMonthDays;
                    relativeMonth = 1;
                }
            }

            days.append({
                day: day,
                currentMonth: relativeMonth === 0,
                today: relativeMonth === 0
                    && day === root.today.getDate()
                    && month === root.today.getMonth()
                    && year === root.today.getFullYear()
            });
        }
    }

    ListModel { id: days }

    Timer {
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
