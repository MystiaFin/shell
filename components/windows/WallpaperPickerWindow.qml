import Quickshell
import QtQuick
import "../../widgets/wallpaper" as WallpaperWidgets
import "../state"
import "../theme"

FloatingWindow {
    id: root

    visible: OverlayState.wallpaperPickerVisible
    implicitWidth: 760
    implicitHeight: 560
    minimumSize: Qt.size(520, 420)
    title: "Wallpapers"
    color: Theme.shellBackgroundColor

    onClosed: OverlayState.hideWallpaperPicker()

    WallpaperWidgets.WallpaperPicker {
        anchors.fill: parent
        onMoveRequested: root.startSystemMove()
    }
}
