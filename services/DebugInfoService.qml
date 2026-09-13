pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string configDirectory: SettingsService.configHome + "/quickshell"
    property string quickshellVersion: "Detecting…"
    property string gitCommit: "Detecting…"

    function openConfigDirectory(): void {
        Quickshell.execDetached(["xdg-open", configDirectory]);
    }

    function reloadShell(): void {
        // Quickshell watches config files by default. Touching shell.qml asks the
        // running instance to perform its normal hot reload without guessing how
        // the user launched the process.
        Quickshell.execDetached(["touch", configDirectory + "/shell.qml"]);
    }

    Process {
        id: versionReader
        running: true
        command: ["quickshell", "--version"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim();
                if (line.length > 0)
                    root.quickshellVersion = line;
            }
        }
        onExited: code => {
            if (code !== 0 && root.quickshellVersion === "Detecting…")
                root.quickshellVersion = "Unavailable";
        }
    }

    Process {
        id: gitReader
        running: true
        command: ["git", "-C", root.configDirectory,
            "rev-parse", "--short", "HEAD"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim();
                if (line.length > 0)
                    root.gitCommit = line;
            }
        }
        onExited: code => {
            if (code !== 0 && root.gitCommit === "Detecting…")
                root.gitCommit = "Not a Git checkout";
        }
    }
}
