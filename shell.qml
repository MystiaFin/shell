pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "Widgets" as WG

ShellRoot {
    id: root
    property color systemColor: "#181825"
    property color systemBlue: "#89b4fa"
    property bool launcherVisible: false

    WG.Wallpaper {}
		WG.Overlay {
						bgColor: root.systemColor
		}
    WG.Bar {
        bgColor: root.systemColor
    }
    WG.NotificationPopups {}
}
