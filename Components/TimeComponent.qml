import QtQuick
import "../Services"

Row {
    id: root
    property color textColor: "#cdd6f4"
    
    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatTime(TimeService.current, "hh:mm AP •")
        color: root.textColor
        font.pixelSize: 16
        font.family: "Poppins"
        font.weight: Font.Light
        leftPadding: 10
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        leftPadding: 3
        text: Qt.formatDate(TimeService.current, "dddd, dd MMM yyyy")
        color: root.textColor
        font.pixelSize: 15
        font.family: "Poppins"
        font.weight: Font.Light
    }
}
