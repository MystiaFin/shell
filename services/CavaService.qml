pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int barCount: 24
    property real amplitudeMultiplier: 1.75
    // Keep barCount aligned with cava-raw.conf's bars value.
    property var bars: Array(barCount).fill(0)
    readonly property string configPath: Qt.resolvedUrl("cava-raw.conf")
        .toString().replace("file://", "")

    Process {
        id: cavaProcess
        running: true
        command: ["cava", "-p", root.configPath]
        stdout: SplitParser {
            onRead: data => {
                const values = data.trim().split(";");
                root.bars = Array.from({ length: root.barCount }, (_, index) => {
                    const value = Number(values[index]);
                    return isNaN(value) ? 0
                        : Math.max(0, Math.min(1,
                            value / 100 * root.amplitudeMultiplier));
                });
            }
        }
        onExited: {
            restartTimer.restart();
        }
    }

    Timer {
        id: restartTimer
        interval: 2000
        onTriggered: cavaProcess.running = true
    }
}
