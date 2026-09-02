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

    function setVolume(value: real): void {
        const clamped = Math.max(0, Math.min(1, value));
        pendingVolume = clamped;
        root.volume = clamped;
        sinkWriteTimer.restart();
    }

    function setMicrophoneVolume(value: real): void {
        const clamped = Math.max(0, Math.min(1, value));
        pendingMicrophoneVolume = clamped;
        root.microphoneVolume = clamped;
        sourceWriteTimer.restart();
    }

    function readOutput(data: string, microphone: bool): void {
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

    Process {
        id: sinkReader
        running: true
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => root.readOutput(data, false)
        }
    }

    Process {
        id: sourceReader
        running: true
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        stdout: SplitParser {
            onRead: data => root.readOutput(data, true)
        }
    }

    Process {
        id: sinkSetter
        onExited: sinkReader.running = true
    }

    Process {
        id: sourceSetter
        onExited: sourceReader.running = true
    }

    Timer {
        id: sinkWriteTimer
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

    Timer {
        id: sourceWriteTimer
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

    Timer {
        id: refreshTimer
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
