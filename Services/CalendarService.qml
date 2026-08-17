import QtQuick

Item {
    id: root

    property var displayDate: new Date()
    property var realDate: new Date()
    property ListModel gridModel: ListModel {}
    property string monthYearString: ""

    Component.onCompleted: {
        refresh()
        timer.start()
    }

    Timer {
        id: timer
        interval: 60000
        repeat: true
        onTriggered: {
            var now = new Date()
            if (now.getDate() !== root.realDate.getDate()) {
                root.realDate = now
                root.refresh()
            }
        }
    }

    function nextMonth() {
        var d = new Date(displayDate)
        d.setMonth(d.getMonth() + 1)
        displayDate = d
        refresh()
    }

    function prevMonth() {
        var d = new Date(displayDate)
        d.setMonth(d.getMonth() - 1)
        displayDate = d
        refresh()
    }

    function jumpToToday() {
        displayDate = new Date()
        refresh()
    }

    function refresh() {
        var year = displayDate.getFullYear()
        var month = displayDate.getMonth()

        root.monthYearString = displayDate.toLocaleString(Qt.locale(), "MMMM yyyy")

        gridModel.clear()

        var firstDayObj = new Date(year, month, 1)
        var startDayIndex = firstDayObj.getDay()
        
        var daysInMonth = new Date(year, month + 1, 0).getDate()
        var daysInPrevMonth = new Date(year, month, 0).getDate()

        for (var i = startDayIndex - 1; i >= 0; i--) {
            gridModel.append({
                "dayNumber": daysInPrevMonth - i,
                "isCurrentMonth": false,
                "isToday": false
            })
        }

        for (var i = 1; i <= daysInMonth; i++) {
            var isToday = (i === realDate.getDate() && 
                           month === realDate.getMonth() && 
                           year === realDate.getFullYear())
            
            gridModel.append({
                "dayNumber": i,
                "isCurrentMonth": true,
                "isToday": isToday
            })
        }

        var remaining = 42 - gridModel.count
        for (var i = 1; i <= remaining; i++) {
            gridModel.append({
                "dayNumber": i,
                "isCurrentMonth": false,
                "isToday": false
            })
        }
    }
}
