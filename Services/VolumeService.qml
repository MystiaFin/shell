import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property real volume: 0.0
    
    function setVolume(newVolume) {
        var clampedVolume = Math.max(0, Math.min(1, newVolume))
        setVolumeProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", clampedVolume.toString()]
        setVolumeProcess.running = true
    }
    
    Process {
        id: setVolumeProcess
        
        onExited: {
            getVolumeProcess.running = true
        }
    }
    
    Process {
        id: getVolumeProcess
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"]
        running: true
        
        stdout: SplitParser {
            onRead: line => {
                var vol = parseFloat(line.trim())
                if (!isNaN(vol)) {
                    root.volume = vol
                }
            }
        }
    }
}
