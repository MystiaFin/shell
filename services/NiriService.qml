pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string socketPath: Quickshell.env("NIRI_SOCKET")
    readonly property bool available: ready
    property bool ready: false
    property bool started: false
    property var pendingWorkspaceId: null
    property var workspaces: []

    function replaceWorkspace(workspace: var): void {
        const next = root.workspaces.slice();
        const index = next.findIndex(item => item.id === workspace.id);
        if (index === -1)
            next.push(workspace);
        else
            next[index] = workspace;
        root.workspaces = next;
    }

    function handleEvent(event: var): void {
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

    function focusWorkspace(id: int): void {
        root.pendingWorkspaceId = id;
        if (!requestSocket.connected) {
            requestSocket.connected = true;
            return;
        }

        root.sendPendingWorkspace();
    }

    function sendPendingWorkspace(): void {
        if (!requestSocket.connected || root.pendingWorkspaceId === null)
            return;

        const id = root.pendingWorkspaceId;
        root.pendingWorkspaceId = null;
        requestSocket.write(JSON.stringify({
            Action: {
                FocusWorkspace: {
                    reference: { Id: id }
                }
            }
        }) + "\n");
        requestSocket.flush();
    }

    Component.onCompleted: {
        root.started = true;
        if (!root.socketPath) {
            console.warn("Niri IPC is unavailable: NIRI_SOCKET is not set");
            return;
        }

        eventSocket.connected = true;
        requestSocket.connected = true;
    }

    Socket {
        id: eventSocket
        property bool awaitingAcknowledgement: false

        path: root.socketPath

        onConnectionStateChanged: {
            if (connected) {
                eventReconnectTimer.stop();
                awaitingAcknowledgement = true;
                write("\"EventStream\"\n");
                flush();
            } else if (root.started && root.socketPath) {
                root.ready = false;
                root.workspaces = [];
                eventReconnectTimer.restart();
            }
        }

        onError: error => {
            console.warn("Niri event socket error:", error);
            connected = false;
        }

        parser: SplitParser {
            onRead: data => {
                try {
                    const message = JSON.parse(data);
                    if (eventSocket.awaitingAcknowledgement) {
                        eventSocket.awaitingAcknowledgement = false;
                        if (message.Ok !== "Handled") {
                            console.warn("Niri rejected event stream request:", data);
                            eventSocket.connected = false;
                        }
                        return;
                    }

                    root.handleEvent(message);
                    if (message.WorkspacesChanged)
                        root.ready = true;
                } catch (error) {
                    console.warn("Could not parse Niri event:", error);
                    if (eventSocket.awaitingAcknowledgement)
                        eventSocket.connected = false;
                }
            }
        }
    }

    Socket {
        id: requestSocket
        path: root.socketPath

        onConnectionStateChanged: {
            if (connected) {
                requestReconnectTimer.stop();
                root.sendPendingWorkspace();
            } else if (root.started && root.socketPath) {
                requestReconnectTimer.restart();
            }
        }

        onError: error => {
            console.warn("Niri request socket error:", error);
            connected = false;
        }

        parser: SplitParser {
            onRead: data => {
                try {
                    const reply = JSON.parse(data);
                    if (reply.Err)
                        console.warn("Niri action failed:", reply.Err);
                } catch (error) {
                    console.warn("Could not parse Niri action reply:", error);
                }
            }
        }
    }

    Timer {
        id: eventReconnectTimer
        interval: 1000
        onTriggered: eventSocket.connected = true
    }

    Timer {
        id: requestReconnectTimer
        interval: 1000
        onTriggered: requestSocket.connected = true
    }
}
