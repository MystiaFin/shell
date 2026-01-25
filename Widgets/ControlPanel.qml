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

    MediaService {
        id: mediaService
        monitorEnabled: true
    }
    CavaService {
        id: cavaService
    }
    VolumeService {
        id: volumeService
        monitorEnabled: !panel.show
    }
    MicService {
        id: micService
        monitorEnabled: !panel.show
    }

    width: 500
    height: 260
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    anchors {
        top: true
    }
    margins.top: show ? 40 : -259

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
        radius: 18
        color: panel.bgColor
        border.width: 2
        border.color: "#313244"

        Column {
            anchors.centerIn: parent
            width: parent.width - 60
            spacing: 24

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
            MediaPlayer {
                width: parent.width
                title: mediaService.title
                artist: mediaService.artist
                artUrl: mediaService.artUrl
                status: mediaService.status
                position: mediaService.position
                length: mediaService.length
                cavaBars: cavaService.bars
                onPlayPause: mediaService.playPause()
                onNext: mediaService.next()
                onPrevious: mediaService.previous()
            }
        }
    }
}
