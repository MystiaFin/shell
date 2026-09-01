pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property bool available: eventStream.running
    property var workspaces: []

    function replaceWorkspace(workspace) {
        const next = root.workspaces.slice();
        const index = next.findIndex(item => item.id === workspace.id);
        if (index === -1)
            next.push(workspace);
        else
            next[index] = workspace;
        root.workspaces = next;
    }

    function handleEvent(event) {
        if (event.WorkspacesChanged) {
            root.workspaces = event.WorkspacesChanged.workspaces.slice();
            return;
        }

        if (event.WorkspaceActivated) {
            const activation = event.WorkspaceActivated;
            const active = root.workspaces.find(item => item.id === activation.id);
            if (!active)
                return;

            root.workspaces = root.workspaces.map(item => {
                const updated = Object.assign({}, item);
                if (item.output === active.output)
                    updated.is_active = item.id === activation.id;
                if (activation.focused)
                    updated.is_focused = item.id === activation.id;
                return updated;
            });
            return;
        }

        if (event.WorkspaceUrgencyChanged) {
            const urgency = event.WorkspaceUrgencyChanged;
            const workspace = root.workspaces.find(item => item.id === urgency.id);
            if (workspace)
                root.replaceWorkspace(Object.assign({}, workspace, { is_urgent: urgency.urgent }));
            return;
        }

        if (event.WorkspaceActiveWindowChanged) {
            const change = event.WorkspaceActiveWindowChanged;
            const workspace = root.workspaces.find(item => item.id === change.workspace_id);
            if (workspace)
                root.replaceWorkspace(Object.assign({}, workspace,
                    { active_window_id: change.active_window_id }));
        }
    }

    function focusWorkspace(index) {
        if (focusProcess.running)
            return;
        focusProcess.command = ["niri", "msg", "action", "focus-workspace", index.toString()];
        focusProcess.running = true;
    }

    property Process eventStream: Process {
        running: true
        command: ["niri", "msg", "--json", "event-stream"]

        stdout: SplitParser {
            onRead: data => {
                try {
                    root.handleEvent(JSON.parse(data));
                } catch (error) {
                    console.warn("Could not parse Niri event:", error);
                }
            }
        }

        onExited: restartTimer.restart()
    }

    property Process focusProcess: Process {}

    property Timer restartTimer: Timer {
        interval: 1000
        onTriggered: eventStream.running = true
    }
}
