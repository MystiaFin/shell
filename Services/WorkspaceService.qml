import QtQuick
import Quickshell.Io

Item {
    id: root

    property int activeIndex: 0
    property string activeWindowTitle: "Desktop"
    property alias model: workspaceModel

    ListModel { id: workspaceModel }

    function focus(idx) {
        focusProcess.command = ["niri", "msg", "action", "focus-workspace", idx.toString()]
        focusProcess.running = true
    }

    Process {
        id: focusProcess
        running: false
        stdout: SplitParser { onRead: data => {} }
    }

    Process {
        id: niriProcess
        command: ["niri", "msg", "--json", "workspaces"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                try {
                    let ws = JSON.parse(data)
                    ws.sort((a, b) => a.idx - b.idx)

                    for (let i = 0; i < ws.length; i++) {
                        let w = ws[i]
                        if (w.is_focused) root.activeIndex = i

                        let itemData = { "workspaceId": w.id, "idx": w.idx, "active": w.is_focused }

                        if (i < workspaceModel.count) {
                            let current = workspaceModel.get(i)
                            if (current.active !== w.is_focused || current.workspaceId !== w.id) {
                                workspaceModel.set(i, itemData)
                            }
                        } else {
                            workspaceModel.append(itemData)
                        }
                    }
                    while (workspaceModel.count > ws.length) workspaceModel.remove(workspaceModel.count - 1)
                } catch (e) {}
            }
        }
    }

    Process {
        id: windowProcess
        command: ["niri", "msg", "--json", "windows"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                try {
                    let windows = JSON.parse(data)
                    let foundFocused = false
                    for (let i = 0; i < windows.length; i++) {
                        if (windows[i].is_focused) {
                            let newTitle = windows[i].title || "Unknown"
                            if (root.activeWindowTitle !== newTitle) root.activeWindowTitle = newTitle
                            foundFocused = true
                            break
                        }
                    }
                    if (!foundFocused && root.activeWindowTitle !== "Desktop") {
                        root.activeWindowTitle = "Desktop"
                    }
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: { 
            niriProcess.running = true
            windowProcess.running = true 
        }
    }
}
