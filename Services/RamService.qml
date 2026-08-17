import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property real usage: 0.0
    property string usedFormatted: "0.0G"
    
    property int _total: 0

    property var ramProcess: Process {
        running: true
        command: ["cat", "/proc/meminfo"]
        
        stdout: SplitParser {
            onRead: data => {
                const parts = data.split(/\s+/)
                
                if (parts[0] === "MemTotal:") {
                    root._total = parseInt(parts[1])
                }
                
                if (parts[0] === "MemAvailable:") {
                    let available = parseInt(parts[1])
                    
                    if (root._total > 0) {
                        let used = root._total - available
                        root.usage = used / root._total
                        let usedGb = used / 1048576
                        root.usedFormatted = usedGb.toFixed(1) + "G"
                    }
                }
            }
        }
    }

    property var updateTimer: Timer {
        interval: 5000
        running: true
        repeat: true
        
        onTriggered: {
            ramProcess.running = false
            ramProcess.running = true
        }
    }

    Component.onCompleted: {
        ramProcess.running = true
    }
}
