import QtQuick
import "../Services"

Row {
    id: root
    property color textColor: "#cdd6f4"
    
    BatteryService {
        id: batteryService
    }
    
    Item {
        width: 34
        height: 24
        anchors.verticalCenter: parent.verticalCenter
        
        Ring {
            id: batteryRing
            anchors.fill: parent
            anchors.leftMargin: 10
            ringColor: batteryService.isCharging ? "#a6e3a1" : (batteryService.batteryLevel > 0.2 ? "#89b4fa" : "#f38ba8")
            bgColor: "#45475a"
            ringWidth: 3
            value: batteryService.batteryLevel
            showNumber: false
        }
        
        Text {
            anchors.centerIn: batteryRing
            text: batteryService.isCharging ? "󰚥" : (
                batteryService.batteryLevel > 0.9 ? "󰁹" :
                batteryService.batteryLevel > 0.8 ? "󰂂" :
                batteryService.batteryLevel > 0.7 ? "󰂁" :
                batteryService.batteryLevel > 0.6 ? "󰂀" :
                batteryService.batteryLevel > 0.5 ? "󰁿" :
                batteryService.batteryLevel > 0.4 ? "󰁾" :
                batteryService.batteryLevel > 0.3 ? "󰁽" :
                batteryService.batteryLevel > 0.2 ? "󰁼" :
                batteryService.batteryLevel > 0.1 ? "󰁻" : "󰁺"
            )
            color: root.textColor
            font.pixelSize: 11
            font.family: "Material Design Icons"
        }
    }
    
    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: batteryService.batteryPercent + "%"
        color: root.textColor
        font.pixelSize: 15
        font.family: "Poppins"
        font.weight: Font.Light
        leftPadding: 6
        topPadding: 1
    }
}
