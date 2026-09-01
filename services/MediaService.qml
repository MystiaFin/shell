pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string title: ""
    property string artist: ""
    property string album: ""
    property string artUrl: ""
    property string playbackStatus: "Stopped"
    property real position: 0
    property real length: 0
    readonly property bool available: title !== "" || artist !== ""
    readonly property bool playing: playbackStatus === "Playing"

    function run(process, command) {
        if (process.running)
            return;
        process.command = ["playerctl", command];
        process.running = true;
    }

    function previous() { run(controlProcess, "previous"); }
    function playPause() { run(controlProcess, "play-pause"); }
    function next() { run(controlProcess, "next"); }

    function clear() {
        title = "";
        artist = "";
        album = "";
        artUrl = "";
        playbackStatus = "Stopped";
        position = 0;
        length = 0;
    }

    property Process metadataMonitor: Process {
        running: true
        command: ["playerctl", "metadata", "--follow", "--format",
            "{{title}}|{{artist}}|{{album}}|{{mpris:artUrl}}|{{status}}|{{position}}|{{mpris:length}}"]

        stdout: SplitParser {
            onRead: data => {
                const fields = data.trim().split("|");
                if (fields.length < 7)
                    return;
                root.title = fields[0] || "";
                root.artist = fields[1] || "";
                root.album = fields[2] || "";
                root.artUrl = fields[3] || "";
                root.playbackStatus = fields[4] || "Stopped";
                root.position = Number(fields[5]) / 1000000 || 0;
                root.length = Number(fields[6]) / 1000000 || 0;
            }
        }

        onExited: {
            root.clear();
            monitorRestart.restart();
        }
    }

    property Process controlProcess: Process {
        onExited: metadataRefresh.running = true
    }

    property Process metadataRefresh: Process {
        command: ["playerctl", "metadata", "--format",
            "{{title}}|{{artist}}|{{album}}|{{mpris:artUrl}}|{{status}}|{{position}}|{{mpris:length}}"]
        stdout: SplitParser {
            onRead: data => {
                const fields = data.trim().split("|");
                if (fields.length >= 7) {
                    root.title = fields[0] || "";
                    root.artist = fields[1] || "";
                    root.album = fields[2] || "";
                    root.artUrl = fields[3] || "";
                    root.playbackStatus = fields[4] || "Stopped";
                    root.position = Number(fields[5]) / 1000000 || 0;
                    root.length = Number(fields[6]) / 1000000 || 0;
                }
            }
        }
    }

    property Timer positionTimer: Timer {
        interval: 1000
        running: root.playing
        repeat: true
        onTriggered: root.position = Math.min(root.length, root.position + 1)
    }

    property Timer monitorRestart: Timer {
        interval: 2000
        onTriggered: metadataMonitor.running = true
    }
}
