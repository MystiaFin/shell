import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property real usage: 0.0
    property int usagePercent: 0
    
    property var _prevIdle: 0
    property var _prevTotal: 0

    property var cpuProcess: Process {
        running: true
        command: ["cat", "/proc/stat"]
        
        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("cpu ")) {
                    const parts = data.split(' ').filter(c => c !== '')
                    
                    let idle = parseInt(parts[4]) + parseInt(parts[5])
                    let total = 0
                    for (let i = 1; i < parts.length; i++) {
                        total += parseInt(parts[i])
                    }

                    let diffIdle = idle - root._prevIdle
                    let diffTotal = total - root._prevTotal
                    
                    if (diffTotal > 0 && root._prevTotal > 0) {
                        let calc = (diffTotal - diffIdle) / diffTotal
                        root.usage = calc
                        root.usagePercent = Math.round(calc * 100)
                    }

                    root._prevIdle = idle
                    root._prevTotal = total
                }
            }
        }
    }

    property var updateTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        
        onTriggered: {
            cpuProcess.running = false
            cpuProcess.running = true
        }
    }
    
    Component.onCompleted: {
        cpuProcess.running = true
    }
}
