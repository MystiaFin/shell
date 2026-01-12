import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property int activeIndex: 0
    property string activeWindowTitle: "Desktop"
    property alias model: workspaceModel

    property bool isSway: (Quickshell.env("XDG_CURRENT_DESKTOP") || "").toLowerCase().includes("sway")

    ListModel {
        id: workspaceModel
    }

    function focus(idx) {
        if (root.isSway) {
            let wsId = workspaceModel.get(idx).workspaceId;
            focusProcess.command = ["swaymsg", "workspace", "number", wsId.toString()];
        } else {
            focusProcess.command = ["niri", "msg", "action", "focus-workspace", idx.toString()];
        }
        focusProcess.running = true;
    }

    Process {
        id: focusProcess
        running: false
        stdout: SplitParser {
            onRead: data => {}
        }
    }

    Process {
        id: swayWsProcess
        running: false
        command: ["swaymsg", "-t", "get_workspaces", "-r"]
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => swayWsProcess.buffer += data
        }

        onExited: (code, status) => {
            if (code !== 0 || swayWsProcess.buffer.trim() === "") {
                swayWsProcess.buffer = "";
                return;
            }

            try {
                let ws = JSON.parse(swayWsProcess.buffer);
                ws.sort((a, b) => a.num - b.num);

                for (let i = 0; i < ws.length; i++) {
                    let w = ws[i];
                    if (w.focused)
                        root.activeIndex = i;

                    let itemData = {
                        "workspaceId": w.num,
                        "idx": w.num,
                        "active": w.focused
                    };

                    if (i < workspaceModel.count) {
                        let current = workspaceModel.get(i);
                        if (current.active !== w.focused || current.workspaceId !== w.num) {
                            workspaceModel.set(i, itemData);
                        }
                    } else {
                        workspaceModel.append(itemData);
                    }
                }
                while (workspaceModel.count > ws.length)
                    workspaceModel.remove(workspaceModel.count - 1);
            } catch (e) {
                console.error("Sway Ws Parse Error: " + e.message);
            }
            swayWsProcess.buffer = "";
        }
    }

    Process {
        id: swayTreeProcess
        running: false
        command: ["swaymsg", "-t", "get_tree", "-r"]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => swayTreeProcess.buffer += data
        }

        onExited: (code, status) => {
            if (code !== 0 || swayTreeProcess.buffer.trim() === "") {
                swayTreeProcess.buffer = "";
                return;
            }

            try {
                let tree = JSON.parse(swayTreeProcess.buffer);
                let focusedNode = findFocusedNode(tree);

                if (focusedNode && focusedNode.name) {
                    if (root.activeWindowTitle !== focusedNode.name) {
                        root.activeWindowTitle = focusedNode.name;
                    }
                } else {
                    if (root.activeWindowTitle !== "Desktop") {
                        root.activeWindowTitle = "Desktop";
                    }
                }
            } catch (e) {
                console.error("Sway Tree Parse Error: " + e.message);
            }
            swayTreeProcess.buffer = "";
        }
    }

    function findFocusedNode(node) {
        if (node.focused)
            return node;
        if (node.nodes) {
            for (let i = 0; i < node.nodes.length; i++) {
                let found = findFocusedNode(node.nodes[i]);
                if (found)
                    return found;
            }
        }
        if (node.floating_nodes) {
            for (let i = 0; i < node.floating_nodes.length; i++) {
                let found = findFocusedNode(node.floating_nodes[i]);
                if (found)
                    return found;
            }
        }
        return null;
    }

    Process {
        id: niriProcess
        running: false
        command: ["niri", "msg", "--json", "workspaces"]

        property string buffer: ""
        stdout: SplitParser {
            onRead: data => niriProcess.buffer += data
        }

        onExited: (code, status) => {
            if (code !== 0 || niriProcess.buffer.trim() === "") {
                niriProcess.buffer = "";
                return;
            }
            try {
                let ws = JSON.parse(niriProcess.buffer);
                ws.sort((a, b) => a.idx - b.idx);
                for (let i = 0; i < ws.length; i++) {
                    let w = ws[i];
                    if (w.is_focused)
                        root.activeIndex = i;
                    let itemData = {
                        "workspaceId": w.id,
                        "idx": w.idx,
                        "active": w.is_focused
                    };
                    if (i < workspaceModel.count) {
                        let current = workspaceModel.get(i);
                        if (current.active !== w.is_focused || current.workspaceId !== w.id) {
                            workspaceModel.set(i, itemData);
                        }
                    } else {
                        workspaceModel.append(itemData);
                    }
                }
                while (workspaceModel.count > ws.length)
                    workspaceModel.remove(workspaceModel.count - 1);
            } catch (e) {}
            niriProcess.buffer = "";
        }
    }

    Process {
        id: niriWindowProcess
        running: false
        command: ["niri", "msg", "--json", "windows"]

        property string buffer: ""
        stdout: SplitParser {
            onRead: data => niriWindowProcess.buffer += data
        }

        onExited: (code, status) => {
            if (code !== 0 || niriWindowProcess.buffer.trim() === "") {
                niriWindowProcess.buffer = "";
                return;
            }
            try {
                let windows = JSON.parse(niriWindowProcess.buffer);
                let foundFocused = false;
                for (let i = 0; i < windows.length; i++) {
                    if (windows[i].is_focused) {
                        let newTitle = windows[i].title || "Unknown";
                        if (root.activeWindowTitle !== newTitle)
                            root.activeWindowTitle = newTitle;
                        foundFocused = true;
                        break;
                    }
                }
                if (!foundFocused && root.activeWindowTitle !== "Desktop") {
                    root.activeWindowTitle = "Desktop";
                }
            } catch (e) {}
            niriWindowProcess.buffer = "";
        }
    }
    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            if (root.isSway) {
                if (!swayWsProcess.running)
                    swayWsProcess.running = true;
                if (!swayTreeProcess.running)
                    swayTreeProcess.running = true;
            } else {
                if (!niriProcess.running)
                    niriProcess.running = true;
                if (!niriWindowProcess.running)
                    niriWindowProcess.running = true;
            }
        }
    }
}
