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
                value: CpuService.usage
                ringColor: CpuService.usage < 0.5
                    ? Theme.statusBarGreenColor
                    : CpuService.usage < 0.8
                        ? Theme.statusBarBlueColor
                        : Theme.statusBarRedColor
            }

            Text {
                anchors.centerIn: parent
                text: "󰘚"
                color: Theme.statusBarTextColor
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 10
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: CpuService.percent + "%"
            color: Theme.statusBarTextColor
            font.family: "Poppins"
            font.pixelSize: 14
            font.weight: Font.Light
        }
    }
}
