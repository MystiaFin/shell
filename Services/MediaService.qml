import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property string title: ""
    property string artist: ""
    property string album: ""
    property string artUrl: ""
    property string status: "Stopped"
    property real position: 0
    property real length: 0
    property bool monitorEnabled: true
    
    function play() {
        playProcess.running = true
    }
    
    function pause() {
        pauseProcess.running = true
    }
    
    function playPause() {
        playPauseProcess.running = true
    }
    
    function next() {
        nextProcess.running = true
    }
    
    function previous() {
        previousProcess.running = true
    }
    
    Process {
        id: playProcess
        command: ["playerctl", "play"]
    }
    
    Process {
        id: pauseProcess
        command: ["playerctl", "pause"]
    }
    
    Process {
        id: playPauseProcess
        command: ["playerctl", "play-pause"]
    }
    
    Process {
        id: nextProcess
        command: ["playerctl", "next"]
    }
    
    Process {
        id: previousProcess
        command: ["playerctl", "previous"]
    }
    
    Process {
        id: metadataProcess
        command: ["playerctl", "metadata", "--format", "{{title}}|{{artist}}|{{album}}|{{mpris:artUrl}}|{{status}}|{{position}}|{{mpris:length}}"]
        running: root.monitorEnabled
        
        stdout: SplitParser {
            onRead: line => {
                var parts = line.trim().split("|")
                if (parts.length >= 7) {
                    root.title = parts[0] || ""
                    root.artist = parts[1] || ""
                    root.album = parts[2] || ""
                    root.artUrl = parts[3] || ""
                    root.status = parts[4] || "Stopped"
                    root.position = parseInt(parts[5]) / 1000000 || 0
                    root.length = parseInt(parts[6]) / 1000000 || 0
                }
            }
        }
    }
    
    Timer {
        id: updateTimer
        interval: 1000
        running: root.monitorEnabled && root.status === "Playing"
        repeat: true
        onTriggered: {
            if (root.monitorEnabled) {
                metadataProcess.running = true
            }
        }
    }
}
