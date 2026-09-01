pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int barCount: 24
    property var bars: Array(barCount).fill(0)
    readonly property string configPath: Qt.resolvedUrl("cava-raw.conf")
        .toString().replace("file://", "")

    property Process visualizer: Process {
        running: false
        command: ["cava", "-p", root.configPath]
        stdout: SplitParser {
            onRead: data => {
                const values = data.trim().split(";");
                root.bars = Array.from({ length: root.barCount }, (_, index) => {
                    const value = Number(values[index]);
                    return isNaN(value) ? 0 : Math.max(0, Math.min(1, value / 100));
                });
            }
        }
        onExited: {
            if (ControlCenterState.visible)
                restartTimer.restart();
        }
    }

    property Timer restartTimer: Timer {
        interval: 2000
        onTriggered: {
            if (ControlCenterState.visible)
                visualizer.running = true;
        }
    }

    property Connections visibilityWatcher: Connections {
        target: ControlCenterState
        function onVisibleChanged() {
            if (ControlCenterState.visible) {
                visualizer.running = true;
            } else {
                visualizer.running = false;
                root.bars = Array(root.barCount).fill(0);
            }
        }
    }
}
