import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property real volume: 0.0
    
    function setVolume(newVolume) {
        var clampedVolume = Math.max(0, Math.min(1, newVolume))
        setVolumeProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", clampedVolume.toString()]
        setVolumeProcess.running = true
    }
    
    Process {
        id: setVolumeProcess
        
        onExited: {
            getMicVolumeProcess.running = true
        }
    }
    
    Process {
        id: getMicVolumeProcess
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $2}'"]
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
