import QtQuick
import "../Services"

Row {
    id: root
    property color textColor: "#cdd6f4"

    CpuService {
        id: cpuService
    }

    Item {
        width: 24
        height: 24
        anchors.verticalCenter: parent.verticalCenter

        Ring {
            id: cpuRing
            anchors.fill: parent
            ringColor: cpuService.usage < 0.5 ? "#a6e3a1" : (cpuService.usage < 0.8 ? "#89b4fa" : "#f38ba8")
            bgColor: "#45475a"
            ringWidth: 3
            value: cpuService.usage
            showNumber: false
        }

        Text {
            anchors.centerIn: cpuRing
            text: "󰘚"
            color: root.textColor
            font.pixelSize: 10
            font.family: "Jetbrains Mono Nerd Font"
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: cpuService.usagePercent + "%"
        color: root.textColor
        font.pixelSize: 15
        font.family: "Poppins"
        font.weight: Font.Light
        leftPadding: 6
        topPadding: 1
    }
}
