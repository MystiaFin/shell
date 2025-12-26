import QtQuick
import "../Services"

Row {
    id: root
    property color textColor: "#cdd6f4"

    RamService {
        id: ramService
    }

    Item {
        width: 24
        height: 24
        anchors.verticalCenter: parent.verticalCenter

        Ring {
            id: ramRing
            anchors.fill: parent
            ringColor: ramService.usage < 0.5 ? "#a6e3a1" : (ramService.usage < 0.8 ? "#89b4fa" : "#f38ba8")
            bgColor: "#45475a"
            ringWidth: 3
            value: ramService.usage
            showNumber: false
        }

        Text {
            anchors.centerIn: ramRing
            text: "󰍛"
            color: root.textColor
            font.pixelSize: 11
            font.family: "Material Design Icons"
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: ramService.usedFormatted
        color: root.textColor
        font.pixelSize: 15
        font.family: "Poppins"
        font.weight: Font.Light
        leftPadding: 6
        topPadding: 1
    }
}
