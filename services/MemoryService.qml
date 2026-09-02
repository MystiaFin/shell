pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real totalKiB: 0
    property real availableKiB: 0
    readonly property real usedKiB: Math.max(0, totalKiB - availableKiB)
    readonly property real usage: totalKiB > 0 ? usedKiB / totalKiB : 0
    readonly property string usedFormatted: (usedKiB / 1048576).toFixed(1) + "G"

    Process {
        id: memoryInfoReader
        running: true
        command: ["cat", "/proc/meminfo"]
        stdout: SplitParser {
            onRead: data => {
                const fields = data.trim().split(/\s+/);
                if (fields[0] === "MemTotal:")
                    root.totalKiB = Number(fields[1]);
                else if (fields[0] === "MemAvailable:")
                    root.availableKiB = Number(fields[1]);
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!memoryInfoReader.running)
                memoryInfoReader.running = true;
        }
    }
}
