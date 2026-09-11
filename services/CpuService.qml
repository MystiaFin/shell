pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real usage: 0
    readonly property int percent: Math.round(usage * 100)
    property real temperature: 0
    property bool temperatureAvailable: false
    property real gpuTemperature: 0
    property bool gpuAvailable: false
    property string gpuName: "Dedicated GPU"
    property real previousIdle: 0
    property real previousTotal: 0

    function update(values: var): void {
        const idle = values[3] + values[4];
        const total = values.reduce((sum, value) => sum + value, 0);
        const totalDelta = total - root.previousTotal;
        const idleDelta = idle - root.previousIdle;

        if (root.previousTotal > 0 && totalDelta > 0)
            root.usage = Math.max(0, Math.min(1, 1 - idleDelta / totalDelta));

        root.previousIdle = idle;
        root.previousTotal = total;
    }

    Process {
        id: cpuStatReader
        running: true
        command: ["cat", "/proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("cpu "))
                    root.update(data.trim().split(/\s+/).slice(1).map(Number));
            }
        }
    }

    Process {
        id: temperatureReader
        command: ["sh", "-c",
            "for d in /sys/class/hwmon/hwmon*; do "
            + "name=$(cat \"$d/name\" 2>/dev/null) || continue; "
            + "case \"$name\" in k10temp|coretemp|zenpower) "
            + "cat \"$d/temp1_input\" 2>/dev/null && exit 0;; esac; done; "
            + "for z in /sys/class/thermal/thermal_zone*; do "
            + "type=$(cat \"$z/type\" 2>/dev/null) || continue; "
            + "case \"$type\" in x86_pkg_temp|cpu-thermal|acpitz) "
            + "cat \"$z/temp\" 2>/dev/null && exit 0;; esac; done; exit 1"]
        stdout: StdioCollector {
            id: temperatureOutput
        }
        onExited: (exitCode, exitStatus) => {
            const value = Number(temperatureOutput.text.trim()) / 1000;
            root.temperatureAvailable = exitCode === 0 && Number.isFinite(value);
            if (root.temperatureAvailable)
                root.temperature = value;
        }
    }

    Process {
        id: gpuTemperatureReader
        command: ["sh", "-c",
            "for card in /sys/class/drm/card[0-9]*; do "
            + "test -r \"$card/device/boot_vga\" || continue; "
            + "test \"$(cat \"$card/device/boot_vga\")\" = 0 || continue; "
            + "vendor=$(cat \"$card/device/vendor\" 2>/dev/null); "
            + "if test \"$vendor\" = 0x10de && command -v nvidia-smi >/dev/null; then "
            + "name=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n1); "
            + "temp=$(nvidia-smi --query-gpu=temperature.gpu "
            + "--format=csv,noheader,nounits | head -n1); "
            + "printf '%s|%s\\n' \"$name\" \"$temp\"; exit 0; fi; "
            + "for h in \"$card/device/hwmon\"/hwmon*; do "
            + "test -r \"$h/temp1_input\" || continue; "
            + "case \"$vendor\" in 0x1002) name='AMD GPU';; "
            + "0x8086) name='Intel GPU';; *) name='Dedicated GPU';; esac; "
            + "temp=$(cat \"$h/temp1_input\"); "
            + "printf '%s|%s\\n' \"$name\" \"$((temp / 1000))\"; exit 0; "
            + "done; done; exit 1"]
        stdout: StdioCollector {
            id: gpuTemperatureOutput
        }
        onExited: (exitCode, exitStatus) => {
            const fields = gpuTemperatureOutput.text.trim().split("|");
            const value = Number(fields[1]);
            root.gpuAvailable = exitCode === 0 && fields.length === 2
                && Number.isFinite(value);
            if (root.gpuAvailable) {
                root.gpuName = fields[0];
                root.gpuTemperature = value;
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!cpuStatReader.running)
                cpuStatReader.running = true;
            if (!temperatureReader.running)
                temperatureReader.running = true;
            if (!gpuTemperatureReader.running)
                gpuTemperatureReader.running = true;
        }
    }

    Component.onCompleted: {
        temperatureReader.running = true;
        gpuTemperatureReader.running = true;
    }
}
