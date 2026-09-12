import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../widgets/wallpaper" as WallpaperWidgets
import "../state"
import "../../services"

PanelWindow {
    id: root

    required property var modelData
    readonly property var targetScreen: modelData
    readonly property bool fallbackTarget: OverlayState.wallpaperOutputName === ""
        && Quickshell.screens.length > 0
        && targetScreen.name === Quickshell.screens[0].name
    readonly property bool requestedVisible: OverlayState.wallpaperPickerVisible
        && (targetScreen.name === OverlayState.wallpaperOutputName || fallbackTarget)
    property bool panelVisible: false

    onRequestedVisibleChanged: {
        if (requestedVisible) {
            closeDelay.stop();
            panelVisible = true;
        } else if (panelVisible) {
            closeDelay.restart();
        }
    }

    screen: targetScreen
    visible: panelVisible
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "wallpaper-picker"
    WlrLayershell.keyboardFocus: requestedVisible
        ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    mask: Region { item: picker }

    Image {
        id: wallpaperTexture

        anchors.fill: parent
        source: DisplayedWallpaperState.sourceForScreen(root.targetScreen.name)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
        mipmap: true
    }

    WallpaperWidgets.WallpaperPicker {
        id: picker

        anchors.centerIn: parent
        width: root.width
        height: Math.max(1, Math.min(380, root.height - 72))
        shown: root.requestedVisible
        requestSerial: OverlayState.wallpaperRequestSerial
        wallpaperSourceItem: wallpaperTexture
        wallpaperRect: Qt.rect(x, y, width, height)
    }

    Timer {
        id: closeDelay

        interval: 180
        onTriggered: root.panelVisible = false
    }
}
