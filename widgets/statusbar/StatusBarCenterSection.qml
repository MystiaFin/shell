import QtQuick
import "../../components/common"
import "../../components/state"
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property date currentTime

    implicitWidth: content.width
    implicitHeight: 26

    component BarText: Text {
        height: 26
        color: Theme.primaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 14
        font.weight: Font.Light
        verticalAlignment: Text.AlignVCenter
    }

    Row {
        id: content

        height: parent.height
        spacing: 2

        Rectangle {
            width: controls.width + 16
            height: 26
            radius: 13
            color: Theme.panelSurfaceColor

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }

            MouseArea {
                anchors.fill: parent
                z: -1
                cursorShape: Qt.PointingHandCursor
                onClicked: OverlayState.toggleControlCenter()
            }

            Row {
                id: controls

                height: parent.height
                anchors.centerIn: parent
                spacing: 8

                StatusRing {
                    width: 18
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    value: AudioService.volume
                    ringWidth: 4
                    ringColor: AudioService.muted
                        ? Theme.mutedTextColor
                        : Theme.accentColor
                    onClicked: OverlayState.toggleControlCenter()
                    onScrolled: delta => AudioService.setVolume(AudioService.volume + delta)
                }

                StatusRing {
                    width: 18
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    value: AudioService.microphoneVolume
                    ringWidth: 4
                    ringColor: AudioService.microphoneMuted
                        ? Theme.mutedTextColor
                        : Theme.accentColor
                    onClicked: OverlayState.toggleControlCenter()
                    onScrolled: delta => AudioService.setMicrophoneVolume(
                        AudioService.microphoneVolume + delta)
                }
            }
        }

        Rectangle {
            width: mediaRow.width + 20
            height: 26
            radius: 13
            color: Theme.panelSurfaceColor

            Row {
                id: mediaRow

                height: parent.height
                anchors.centerIn: parent
                spacing: 7

                Text {
                    height: parent.height
                    text: Icons.media
                    color: Theme.successColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                }

                BarText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(180, implicitWidth)
                    text: MediaService.available
                        ? MediaService.artist + " - " + MediaService.title
                        : "No media"
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }
            }
        }

        BarText {
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 8
            text: Qt.formatTime(root.currentTime, "hh:mm AP") + "  •  "
                + Qt.formatDate(root.currentTime, "dddd, dd MMM yyyy")
            font.pixelSize: 15
        }
    }
}
