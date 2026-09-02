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
    property real positionSeconds: 0
    property real durationSeconds: 0
    readonly property bool available: title !== "" || artist !== ""
    readonly property bool playing: playbackStatus === "Playing"
    readonly property real microsecondsPerSecond: 1000000
    readonly property string metadataSeparator: "␟"
    readonly property string metadataFormat: "{{title}}" + metadataSeparator
        + "{{artist}}" + metadataSeparator + "{{album}}" + metadataSeparator
        + "{{mpris:artUrl}}" + metadataSeparator + "{{status}}" + metadataSeparator
        + "{{position}}" + metadataSeparator + "{{mpris:length}}"

    function run(process: Process, command: string): void {
        if (process.running)
            return;
        process.command = ["playerctl", command];
        process.running = true;
    }

    function previous(): void { run(controlProcess, "previous"); }
    function playPause(): void { run(controlProcess, "play-pause"); }
    function next(): void { run(controlProcess, "next"); }

    function clear(): void {
        title = "";
        artist = "";
        album = "";
        artUrl = "";
        playbackStatus = "Stopped";
        positionSeconds = 0;
        durationSeconds = 0;
    }

    function applyMetadataLine(data: string): void {
        const fields = data.trim().split(metadataSeparator);
        if (fields.length < 7)
            return;
        title = fields[0] || "";
        artist = fields[1] || "";
        album = fields[2] || "";
        artUrl = fields[3] || "";
        playbackStatus = fields[4] || "Stopped";
        positionSeconds = Number(fields[5]) / microsecondsPerSecond || 0;
        durationSeconds = Number(fields[6]) / microsecondsPerSecond || 0;
    }

    Process {
        id: metadataMonitor
        running: true
        command: ["playerctl", "metadata", "--follow", "--format", root.metadataFormat]

        stdout: SplitParser {
            onRead: data => root.applyMetadataLine(data)
        }

        onExited: {
            root.clear();
            monitorRestart.restart();
        }
    }

    Process {
        id: controlProcess
        onExited: metadataRefresh.running = true
    }

    Process {
        id: metadataRefresh
        command: ["playerctl", "metadata", "--format", root.metadataFormat]
        stdout: SplitParser {
            onRead: data => root.applyMetadataLine(data)
        }
    }

    Timer {
        id: positionTimer
        interval: 1000
        running: root.playing
        repeat: true
        onTriggered: root.positionSeconds = Math.min(root.durationSeconds,
            root.positionSeconds + 1)
    }

    Timer {
        id: monitorRestart
        interval: 2000
        onTriggered: metadataMonitor.running = true
    }
}
