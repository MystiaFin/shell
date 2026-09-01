import Quickshell
import "components"

ShellRoot {
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
