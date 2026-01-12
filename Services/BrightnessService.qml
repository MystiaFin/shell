import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int percentage: 0

    function setBrightness(newVal) {
        var clamped = Math.max(0, Math.min(100, Math.round(newVal)))
        root.percentage = clamped
        setProcess.command = ["brightnessctl", "s", clamped + "%"]
        setProcess.running = true
    }

    Process {
        id: setProcess
        onExited: {
            getProcess.running = true
        }
    }

    Process {
        id: getProcess
        command: ["brightnessctl", "-m"] 
        running: true

        stdout: SplitParser {
            onRead: line => {
                var parts = line.split(",")
                if (parts.length >= 4) {
                    var p = parts[3].replace("%", "")
                    var vol = parseInt(p)
                    if (!isNaN(vol)) {
                        root.percentage = vol
                    }
                }
            }
        }
    }
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: getProcess.running = true
    }
}
