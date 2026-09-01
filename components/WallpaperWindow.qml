import Quickshell
import QtQuick
import "../services"

FloatingWindow {
    id: root

    visible: WallpaperPickerState.visible
    implicitWidth: 760
    implicitHeight: 560
    minimumSize: Qt.size(520, 420)
    title: "Wallpapers"
    color: Theme.statusBarBackgroundColor

    onClosed: WallpaperPickerState.hide()

    WallpaperPicker {
        anchors.fill: parent
        onMoveRequested: root.startSystemMove()
    }
}
