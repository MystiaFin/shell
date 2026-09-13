import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    width: 0
    height: 0

    property var sessions: []
    property var pendingSessions: []

    readonly property bool running:
        sessionReader.running

    function refresh(): void {
        if (sessionReader.running)
            return;

        pendingSessions = [];
        sessionReader.running = true;
    }

    function launchSession(sessionName: string): bool {
        const terminal = Quickshell.env("TERMINAL");

        if (!terminal || terminal.length === 0) {
            console.error(
                "Cannot launch tmux session: TERMINAL is not set"
            );

            return false;
        }

        Quickshell.execDetached([
            terminal,
            "--",
            "tmux",
            "attach-session",
            "-t",
            sessionName
        ]);

        return true;
    }

    Process {
        id: sessionReader

        command: [
            "tmux",
            "list-sessions",
            "-F",
            "#{session_name}"
        ]

        stdout: SplitParser {
            onRead: data => {
                const sessionName = data.trim();

                if (sessionName.length === 0)
                    return;

                root.pendingSessions =
                    root.pendingSessions.concat(
                        sessionName
                    );
            }
        }

        onExited: {
            root.sessions =
                root.pendingSessions.sort();
        }
    }
}
