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
    }
    MicService {
        id: micService
    }
    
    width: 500
    height: 250
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    anchors {
        top: true
    }
    margins.top: show ? 44 : -220
    
		WlrLayershell.layer: WlrLayer.Top
    
    Behavior on margins.top {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
    
    Rectangle {
        anchors.fill: parent
        radius: 20
        color: panel.bgColor
        border {
            color: panel.borderColor
            width: 2
        }
        Column {
            anchors.centerIn: parent
            spacing: 20
            Ring {
                width: 90
                height: 90
                ringColor: "#89b4fa"
                ringWidth: 8
                value: volumeService.volume
                onScroll: delta => volumeService.setVolume(volumeService.volume + delta)
            }
            Ring {
                width: 90
                height: 90
                ringColor: "#f38ba8"
                ringWidth: 8
                value: micService.volume
                onScroll: delta => micService.setVolume(micService.volume + delta)
            }
        }
    }
}
