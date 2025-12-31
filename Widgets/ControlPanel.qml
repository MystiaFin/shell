import Quickshell
import QtQuick
import "../Components"
import "../Services"
import Quickshell.Wayland

PanelWindow {
    id: panel
    property color bgColor
    property color borderColor
    property bool show: false

    VolumeService {
        id: volumeService
        monitorEnabled: !panel.show
    }
    MicService {
        id: micService
        monitorEnabled: !panel.show
    }

    width: 500
    height: 250
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    anchors {
        top: true
    }
    margins.top: show ? 40 : -246

    Behavior on margins.top {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "popup"

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: parent.height - 4
        y: 4

        radius: 20
        color: panel.bgColor

        Column {
            anchors.centerIn: parent
            width: parent.width - 60
            spacing: 20

            SliderController {
                width: parent.width
                sliderColor: "#89b4fa"
                startIcon: "󰕾"

                value: volumeService.volume
                onMoved: newValue => volumeService.setVolume(newValue)
            }

            SliderController {
                width: parent.width
                sliderColor: "#f38ba8"
                startIcon: "󰍬"

                value: micService.volume
                onMoved: newValue => micService.setVolume(newValue)
            }
        }
    }
}
