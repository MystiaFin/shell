import QtQuick
import Quickshell.Io

QtObject {
    id: root
    
    property real batteryLevel: 0.0
    property int batteryPercent: 0
    property string status: "Unknown"
    property bool isCharging: false
    
    property var capacityProcess: Process {
        running: true
        command: ["cat", "/sys/class/power_supply/BAT1/capacity"]
        
        stdout: SplitParser {
            onRead: data => {
                let value = parseInt(data.trim())
                if (!isNaN(value)) {
                    root.batteryPercent = value
                    root.batteryLevel = value / 100.0
                }
            }
        }
    }
    
    property var statusProcess: Process {
        running: true
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        
        stdout: SplitParser {
            onRead: data => {
                root.status = data.trim()
                root.isCharging = (root.status === "Charging")
            }
        }
    }
    
    property var updateTimer: Timer {
        interval: 5000
        running: true
        repeat: true
        
        onTriggered: {
            capacityProcess.running = false
            statusProcess.running = false
            
            capacityProcess.running = true
            statusProcess.running = true
        }
    }
    
    Component.onCompleted: {
        // Initial read
        capacityProcess.running = true
        statusProcess.running = true
    }
}
