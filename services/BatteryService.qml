pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool available: false
    property int percent: 0
    property string status: "Unknown"
    readonly property real level: percent / 100
    readonly property bool charging: status === "Charging"

    readonly property string icon: {
        if (charging)
            return "󰚥";
        if (percent > 90) return "󰁹";
        if (percent > 80) return "󰂂";
        if (percent > 70) return "󰂁";
        if (percent > 60) return "󰂀";
        if (percent > 50) return "󰁿";
        if (percent > 40) return "󰁾";
        if (percent > 30) return "󰁽";
        if (percent > 20) return "󰁼";
        if (percent > 10) return "󰁻";
        return "󰁺";
    }

    property Process reader: Process {
        running: true
        command: ["sh", "-c", "for b in /sys/class/power_supply/*; do [ \"$(cat \"$b/type\" 2>/dev/null)\" = Battery ] || continue; printf '%s|%s\\n' \"$(cat \"$b/capacity\")\" \"$(cat \"$b/status\")\"; exit; done"]
        stdout: SplitParser {
            onRead: data => {
                const fields = data.trim().split("|");
                const value = Number(fields[0]);
                if (!isNaN(value)) {
                    root.available = true;
                    root.percent = Math.max(0, Math.min(100, value));
                    root.status = fields[1] || "Unknown";
                }
            }
        }
    }

    property Timer timer: Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!reader.running)
                reader.running = true;
        }
    }
}
