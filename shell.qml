pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import "Widgets" as WG
import Quickshell.Wayland

ShellRoot {
    id: root
    property color systemColor: "#181825"
    property color systemBlue: "#89b4fa"
    property bool launcherVisible: false
    property bool sidebarVisible: false

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            root.launcherVisible = !root.launcherVisible;
        }
    }

    WG.Wallpaper {}
    WG.ControlPanel {}
    WG.Sidebar {
        bgColor: root.systemColor
        visible: root.sidebarVisible
    }
    WG.Bar {
        bgColor: root.systemColor
        sidebarVisible: root.sidebarVisible
        onToggleSidebar: root.sidebarVisible = !root.sidebarVisible
    }
    WG.Overlay {
        bgColor: root.systemColor
    }
    WG.NotificationPopups {}
    WG.LauncherV2 {
        visible: root.launcherVisible
        onRequestClose: root.launcherVisible = false
    }
}
