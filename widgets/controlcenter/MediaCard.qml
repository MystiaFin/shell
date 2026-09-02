import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../../components/theme"
import "../../services"

Rectangle {
    id: mediaCard

    function formatTime(seconds: real): string {
        const minutes = Math.floor(Math.max(0, seconds) / 60);
        const remainder = Math.floor(Math.max(0, seconds) % 60);
        return minutes + ":" + (remainder < 10 ? "0" : "") + remainder;
    }

    radius: 22
    color: Theme.panelSurfaceColor

    ColumnLayout {
        anchors {
            fill: parent
            margins: 18
        }
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 112
            spacing: 14

            ClippingRectangle {
                Layout.preferredWidth: 112
                Layout.preferredHeight: 112
                radius: 14
                color: Theme.surfaceBorderColor

                Image {
                    anchors.fill: parent
                    source: MediaService.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    visible: MediaService.artUrl !== ""
                }

                Text {
                    anchors.centerIn: parent
                    visible: MediaService.artUrl === ""
                    text: Icons.emptyMedia
                    color: Theme.mutedTextColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 42
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4

                Item { Layout.fillHeight: true }

                Text {
                    Layout.fillWidth: true
                    text: MediaService.title || "Nothing playing"
                    color: Theme.primaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 17
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    Layout.fillWidth: true
                    text: MediaService.artist || "Open Spotify or another media player"
                    color: Theme.mutedTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: MediaService.album !== ""
                    text: MediaService.album
                    color: Theme.secondaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }

                Item { Layout.fillHeight: true }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 24

            Row {
                id: audioVisualizerBars

                anchors.fill: parent
                spacing: 3

                Repeater {
                    model: CavaService.bars

                    Item {
                        required property real modelData

                        width: (audioVisualizerBars.width
                            - (CavaService.barCount - 1) * audioVisualizerBars.spacing)
                            / CavaService.barCount
                        height: audioVisualizerBars.height

                        Rectangle {
                            anchors {
                                right: parent.right
                                bottom: parent.bottom
                                left: parent.left
                            }
                            height: Math.max(3, parent.height * modelData)
                            radius: width / 2
                            color: Theme.accentColor

                            Behavior on height {
                                NumberAnimation {
                                    duration: 65
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: mediaCard.formatTime(MediaService.positionSeconds)
                color: Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 11
            }

            Rectangle {
                Layout.fillWidth: true
                height: 5
                radius: height / 2
                color: Theme.surfaceBorderColor

                Rectangle {
                    width: MediaService.durationSeconds > 0
                        ? Math.min(parent.width, MediaService.positionSeconds
                            / MediaService.durationSeconds * parent.width)
                        : 0
                    height: parent.height
                    radius: parent.radius
                    color: Theme.accentColor

                    Behavior on width { NumberAnimation { duration: 200 } }
                }
            }

            Text {
                text: mediaCard.formatTime(MediaService.durationSeconds)
                color: Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 11
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            spacing: 10

            Item { Layout.fillWidth: true }

            MediaControlButton {
                icon: Icons.previousTrack
                onClicked: MediaService.previous()
            }
            MediaControlButton {
                primaryAction: true
                icon: MediaService.playing ? Icons.pause : Icons.play
                onClicked: MediaService.playPause()
            }
            MediaControlButton {
                icon: Icons.nextTrack
                onClicked: MediaService.next()
            }

            Item { Layout.fillWidth: true }
        }
    }
}
