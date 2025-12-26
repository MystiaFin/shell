pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "Widgets" as WG

ShellRoot {
    id: root
    property color systemColor: "#181825"
    property color systemBlue: "#89b4fa"
    property bool launcherVisible: false
    property bool sidebarVisible: false  
    
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
}
