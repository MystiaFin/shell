pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "Widgets" as WG

ShellRoot {
    id: root
    property color systemColor: "#11111b"

		WG.Wallpaper {}
		WG.Overlay {}

    // Widgets
    WG.Bar {
        bgColor: root.systemColor
    }
    WG.NotificationPopups {}
		// WG.FloatingBottom {}
}
