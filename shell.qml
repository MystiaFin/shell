pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "Widgets" as WG

ShellRoot {
    id: root
    property color systemColor: "#1E1E2E"

    Variants {
        model: Quickshell.screens

        delegate: Wallpaper {
            bgColor: root.systemColor
        }
    }

    // Widgets
    WG.Bar {
        bgColor: root.systemColor
    }
    WG.NotificationPopups {}
}
