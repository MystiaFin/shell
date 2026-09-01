import Quickshell
import "components"
import "services"

ShellRoot {
    readonly property var terminalThemeService: TerminalThemeService

    WallpaperWindow {}

    Variants {
        model: Quickshell.screens

        Wallpaper {}
    }

    Variants {
        model: Quickshell.screens

        Desktop {}
    }

    Variants {
        model: Quickshell.screens

        StatusBar {}
    }

    Variants {
        model: Quickshell.screens

        ScreenMask {}
    }
}
