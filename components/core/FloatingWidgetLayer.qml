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
    readonly property url publishedWallpaper:
        DisplayedWallpaperState.sourceForScreen(targetScreen.name)
    readonly property url displayedWallpaper:
        publishedWallpaper.toString() !== ""
            ? publishedWallpaper : WallpaperService.source
    readonly property real widgetInset: 32 * SettingsService.uiScale
    readonly property bool barOnTop: SettingsService.statusBarPosition === "top"
    readonly property real reservedBarHeight: SettingsService.statusBarAutoHide
        ? 0 : ShellMetrics.statusBarHeight
    readonly property rect usableArea: Qt.rect(
        widgetInset,
        widgetInset + (barOnTop ? reservedBarHeight : 0),
        Math.max(1, width - widgetInset * 2),
        Math.max(1, height - widgetInset * 2 - reservedBarHeight))
    readonly property bool floatingWidgetsVisible:
        SettingsService.anyFloatingWidgetEnabled()
        && StartupState.maskRevealFinished(targetScreen.name)
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
