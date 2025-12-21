import QtQuick
import "../Components"
import "../Services"

Rectangle {
    height: 26
    width: buttonContent.width + 16
    color: "#313244"
    topLeftRadius: 13
    bottomLeftRadius: 13

    VolumeService {
        id: volumeService
    }
    MicService {
        id: micService
    }

    Row {
        id: buttonContent
        anchors.centerIn: parent
        spacing: 6

        Ring {
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            ringColor: "#89b4fa"
            bgColor: "#45475a"
            ringWidth: 4
            value: volumeService.volume
            showNumber: false
            onScroll: delta => volumeService.setVolume(volumeService.volume + delta)
        }

        Ring {
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            ringColor: "#f38ba8"
            bgColor: "#45475a"
            ringWidth: 4
            showNumber: false
            value: micService.volume
            onScroll: delta => micService.setVolume(micService.volume + delta)
        }
    }
}
