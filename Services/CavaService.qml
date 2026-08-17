import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var bars: []
    property int barCount: 20

    Component.onCompleted: {
        var initial = [];
        for (var i = 0; i < barCount; i++) {
            initial.push(0);
        }
        bars = initial;
    }

    Process {
        id: cavaProcess
        command: ["sh", "-c", "cava -p ~/.config/cava/config-raw"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                var values = data.trim().split(';');
                var newBars = [];

                for (var i = 0; i < barCount; i++) {
                    if (i < values.length && values[i] !== "") {
                        var normalized = parseInt(values[i]) / 100.0;
                        newBars.push(Math.min(1.0, Math.max(0.0, normalized)));
                    } else {
                        newBars.push(0);
                    }
                }
                root.bars = newBars;
            }
        }
    }
}
