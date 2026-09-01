import QtQuick
import "../services"

Item {
    id: root

    visible: BatteryService.available
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
                value: BatteryService.level
                ringColor: BatteryService.charging
                    ? Theme.statusBarGreenColor
                    : BatteryService.percent > 20
                        ? Theme.statusBarBlueColor
                        : Theme.statusBarRedColor
            }

            Text {
                anchors.centerIn: parent
                text: BatteryService.icon
                color: Theme.statusBarTextColor
                font.family: "Material Design Icons"
                font.pixelSize: 10
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: BatteryService.percent + "%"
            color: Theme.statusBarTextColor
            font.family: "Poppins"
            font.pixelSize: 14
            font.weight: Font.Light
        }
    }
}
