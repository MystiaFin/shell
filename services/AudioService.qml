pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real volume: 0
    property real microphoneVolume: 0
    property bool muted: false
    property bool microphoneMuted: false
    property real pendingVolume: 0
    property real pendingMicrophoneVolume: 0

    function setVolume(value) {
        const clamped = Math.max(0, Math.min(1, value));
        pendingVolume = clamped;
        root.volume = clamped;
        sinkWriteTimer.restart();
    }

    function setMicrophoneVolume(value) {
        const clamped = Math.max(0, Math.min(1, value));
        pendingMicrophoneVolume = clamped;
        root.microphoneVolume = clamped;
        sourceWriteTimer.restart();
    }

    function readOutput(data, microphone) {
        const match = data.match(/Volume:\s+([0-9.]+)/);
        if (!match)
            return;

        if (microphone) {
            root.microphoneVolume = Number(match[1]);
            root.microphoneMuted = data.includes("MUTED");
        } else {
            root.volume = Number(match[1]);
            root.muted = data.includes("MUTED");
        }
    }

    property Process sinkReader: Process {
        running: true
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => root.readOutput(data, false)
        }
    }

    property Process sourceReader: Process {
        running: true
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        stdout: SplitParser {
            onRead: data => root.readOutput(data, true)
        }
    }

    property Process sinkSetter: Process {
        onExited: sinkReader.running = true
    }

    property Process sourceSetter: Process {
        onExited: sourceReader.running = true
    }

    property Timer sinkWriteTimer: Timer {
        interval: 40
        onTriggered: {
            if (sinkSetter.running) {
                restart();
                return;
            }
            sinkSetter.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@",
                root.pendingVolume.toFixed(2)];
            sinkSetter.running = true;
        }
    }

    property Timer sourceWriteTimer: Timer {
        interval: 40
        onTriggered: {
            if (sourceSetter.running) {
                restart();
                return;
            }
            sourceSetter.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@",
                root.pendingMicrophoneVolume.toFixed(2)];
            sourceSetter.running = true;
        }
    }

    property Timer refreshTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!sinkReader.running)
                sinkReader.running = true;
            if (!sourceReader.running)
                sourceReader.running = true;
        }
    }
}
