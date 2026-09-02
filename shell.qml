import Quickshell
import QtQuick
import "components/core"
import "components/state"
import "components/windows"
import "integrations"
import "services"
import "widgets/statusbar"

ShellRoot {
    Component.onCompleted: ThemeExportService.activateExternalThemeIntegration()

    Binding {
        target: NetworkService
        property: "scanningRequested"
        value: OverlayState.utilityCenterVisible
            && OverlayState.utilityPage === "wifi"
    }

    Binding {
        target: BluetoothService
        property: "scanningRequested"
        value: OverlayState.utilityCenterVisible
            && OverlayState.utilityPage === "bluetooth"
    }

    WallpaperPickerWindow {}

    Variants {
        model: Quickshell.screens

        WallpaperLayer {}
    }

    Variants {
        model: Quickshell.screens

        ScreenOverlay {}
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
