import QtQuick
import QtQuick.Layouts
import "../../components/common"
import "../../components/state"
import "../../components/theme"
import "../../services"

Item {
    id: controlCenter

    property real topPadding: ShellMetrics.panelScreenEdgeOverlap + 28

    GridLayout {
        anchors {
            fill: parent
            topMargin: controlCenter.topPadding
            rightMargin: 18
            bottomMargin: 18
            leftMargin: 18
        }
        columns: 2
        columnSpacing: 14

        Rectangle {
            Layout.preferredWidth: 120
            Layout.fillHeight: true
            radius: 20
            color: Theme.panelSurfaceColor

            RowLayout {
                width: 100
                anchors {
                    top: parent.top
                    topMargin: 6
                    bottom: parent.bottom
                    bottomMargin: 6
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 4

                VerticalAudioFader {
                    icon: Icons.volume
                    value: AudioService.volume
                    muted: AudioService.muted
                    accentColor: Theme.accentColor
                    onValueMoved: value => AudioService.setVolume(value)
                }

                VerticalAudioFader {
                    icon: Icons.microphone
                    value: AudioService.microphoneVolume
                    muted: AudioService.microphoneMuted
                    accentColor: Theme.accentColor
                    onValueMoved: value => AudioService.setMicrophoneVolume(value)
                }
            }
        }

        MediaCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    HoverHandler {
        id: controlCenterHover
    }

    HoverDismissController {
        active: OverlayState.controlCenterVisible
        panelHovered: controlCenterHover.hovered
        externalHovered: OverlayState.statusBarHovered
        onDismissRequested: OverlayState.hideControlCenter()
    }
}
