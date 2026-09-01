import QtQuick
import "../services"

Item {
    id: root

    implicitWidth: content.width
    implicitHeight: 26

    Row {
        id: content
        height: parent.height
        spacing: 6

        Item {
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter

            StatusRing {
                anchors.fill: parent
                value: MemoryService.usage
                ringColor: MemoryService.usage < 0.5
                    ? Theme.statusBarGreenColor
                    : MemoryService.usage < 0.8
                        ? Theme.statusBarAccentColor
                        : Theme.statusBarRedColor
            }

            Text {
                anchors.centerIn: parent
                text: "󰍛"
                color: Theme.statusBarTextColor
                font.family: "Material Design Icons"
                font.pixelSize: 10
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: MemoryService.usedFormatted
            color: Theme.statusBarTextColor
            font.family: "Poppins"
            font.pixelSize: 14
            font.weight: Font.Light
        }
    }
}
