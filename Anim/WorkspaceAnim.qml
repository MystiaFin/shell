import QtQuick

Rectangle {
    id: root
    
    property int targetIndex: 0
    property int cellWidth: 30
    property int startOffset: 3

    width: 26
    height: 26
    radius: 13
    color: "#e5c890"

    x: startOffset + (targetIndex * cellWidth)

    Behavior on x {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
}
