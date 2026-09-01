pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real usage: 0
    readonly property int percent: Math.round(usage * 100)
    property real previousIdle: 0
    property real previousTotal: 0

    function update(values) {
        const idle = values[3] + values[4];
        const total = values.reduce((sum, value) => sum + value, 0);
        const totalDelta = total - root.previousTotal;
        const idleDelta = idle - root.previousIdle;

        if (root.previousTotal > 0 && totalDelta > 0)
            root.usage = Math.max(0, Math.min(1, 1 - idleDelta / totalDelta));

        root.previousIdle = idle;
        root.previousTotal = total;
    }

    property Process reader: Process {
        running: true
        command: ["cat", "/proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("cpu "))
                    root.update(data.trim().split(/\s+/).slice(1).map(Number));
            }
        }
    }

    property Timer timer: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!reader.running)
                reader.running = true;
        }
    }
}
