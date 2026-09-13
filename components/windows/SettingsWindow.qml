import Quickshell
import QtQuick
import "../../widgets/settings" as SettingsWidgets
import "../state"
import "../theme"

FloatingWindow {
    id: root

    title: "Quickshell Settings"
    visible: OverlayState.settingsVisible
    color: Theme.shellBackgroundColor
    implicitWidth: 980
    implicitHeight: 680
    minimumSize: Qt.size(760, 620)
    maximumSize: Qt.size(1280, 900)

    onClosed: OverlayState.hideSettings()

    SettingsWidgets.SettingsPage {
        anchors.fill: parent
        shown: root.visible
        requestSerial: OverlayState.settingsRequestSerial
    }
}
