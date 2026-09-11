import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../services"
import "../../widgets/overview"
import "../state"
import "../theme"

PanelWindow {
    id: root

    required property var modelData
    readonly property var targetScreen: modelData
    readonly property url displayedWallpaper:
        DisplayedWallpaperState.sourceForScreen(targetScreen.name)
    readonly property rect usableArea: Qt.rect(
        32,
        ShellMetrics.statusBarHeight + 32,
        Math.max(1, width - 64),
        Math.max(1, height - ShellMetrics.statusBarHeight - 64))
    readonly property bool floatingWidgetsVisible:
        StartupState.maskRevealFinished(targetScreen.name)
        && FloatingWidgetVisibilityService.visibleOnOutput(targetScreen.name)

    screen: targetScreen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "floating-widgets"

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    mask: Region {}

    Image {
        id: wallpaperTexture

        anchors.fill: parent
        source: root.displayedWallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
        mipmap: true
        visible: true
    }

    DesktopOverview {
        anchors.fill: parent
        screenName: root.targetScreen.name
        usableArea: root.usableArea
        wallpaperSource: root.displayedWallpaper
        wallpaperSourceItem: wallpaperTexture
        shown: root.floatingWidgetsVisible
    }
}
