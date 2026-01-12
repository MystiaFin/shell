import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property real volume: 0.0
    property bool monitorEnabled: true
    
    function setVolume(newVolume) {
        var clampedVolume = Math.max(0, Math.min(1, newVolume))
        clampedVolume = Math.round(clampedVolume * 100) / 100
        
        setVolumeProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", clampedVolume.toString()]
        setVolumeProcess.running = true
    }
    
    Process {
        id: setVolumeProcess
    }
    
    Process {
        id: getVolumeProcess
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"]
        running: true
        
        stdout: SplitParser {
            onRead: line => {
                var vol = parseFloat(line.trim())
                if (!isNaN(vol)) {
                    root.volume = Math.round(vol * 100) / 100
                }
            }
        }
    }
    
    Process {
        id: monitor
        running: root.monitorEnabled
        command: ["pw-mon"]
        
        stdout: SplitParser {
            onRead: line => {
                if (line.includes("changed") || line.includes("Props")) {
                    if (root.monitorEnabled) {
                        getVolumeProcess.running = true
                    }
                }
            }
        }
    }
}
