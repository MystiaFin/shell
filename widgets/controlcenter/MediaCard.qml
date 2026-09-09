import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../../components/theme"
import "../../services"

Rectangle {
    id: mediaCard

    readonly property real artworkSize: Math.min(220,
        Math.max(112, width * 0.36))
    readonly property bool multiplePlayers: MediaService.playerCount > 1
    property real switchOffset: 0
    property real switchOpacity: 1

    function switchPlayer(direction: int): void {
        if (!multiplePlayers || playerSwitch.running)
            return;
        playerSwitch.direction = direction;
        playerSwitch.start();
    }

    function formatTime(seconds: real): string {
        const minutes = Math.floor(Math.max(0, seconds) / 60);
        const remainder = Math.floor(Math.max(0, seconds) % 60);
        return minutes + ":" + (remainder < 10 ? "0" : "") + remainder;
    }

    radius: ShellMetrics.radiusExtraLarge
    color: Theme.panelSurfaceColor

    Item {
        id: contentViewport

        anchors {
            fill: parent
            margins: 18
            leftMargin: mediaCard.multiplePlayers ? 50 : 18
            rightMargin: mediaCard.multiplePlayers ? 50 : 18
        }
        clip: true

        RowLayout {
            width: contentViewport.width
            height: contentViewport.height
            spacing: 16

            ClippingRectangle {
            Layout.preferredWidth: mediaCard.artworkSize
            Layout.preferredHeight: mediaCard.artworkSize
            Layout.alignment: Qt.AlignVCenter
            radius: ShellMetrics.radiusLarge
            color: Theme.surfaceBorderColor
            opacity: mediaCard.switchOpacity
            transform: Translate { x: mediaCard.switchOffset }

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
                font.pixelSize: 52
            }
        }

            ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: mediaCard.artworkSize
            Layout.maximumHeight: mediaCard.artworkSize
            Layout.alignment: Qt.AlignVCenter
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                opacity: mediaCard.switchOpacity
                transform: Translate { x: mediaCard.switchOffset }

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
                    maximumLineCount: 1
                }

                Text {
                    Layout.fillWidth: true
                    visible: MediaService.album !== ""
                    text: MediaService.album
                    color: Theme.secondaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            Item { Layout.fillHeight: true }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                Layout.maximumHeight: 64

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
                spacing: 8
                opacity: mediaCard.switchOpacity
                transform: Translate { x: mediaCard.switchOffset }

                Text {
                    text: mediaCard.formatTime(MediaService.positionSeconds)
                    color: Theme.mutedTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 10
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

                        Behavior on width {
                            NumberAnimation { duration: 200 }
                        }
                    }
                }

                Text {
                    text: mediaCard.formatTime(MediaService.durationSeconds)
                    color: Theme.mutedTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 10
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                spacing: 10
                opacity: mediaCard.switchOpacity
                transform: Translate { x: mediaCard.switchOffset }

                Item { Layout.fillWidth: true }

                MediaControlButton {
                    enabled: MediaService.canGoPrevious
                    icon: Icons.previousTrack
                    onClicked: MediaService.previous()
                }
                MediaControlButton {
                    enabled: MediaService.canTogglePlaying
                    primaryAction: true
                    icon: MediaService.playing ? Icons.pause : Icons.play
                    onClicked: MediaService.playPause()
                }
                MediaControlButton {
                    enabled: MediaService.canGoNext
                    icon: Icons.nextTrack
                    onClicked: MediaService.next()
                }

                Item { Layout.fillWidth: true }
            }
        }
    }
    }

    Rectangle {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            margins: 18
            leftMargin: 10
        }
        width: 30
        visible: mediaCard.multiplePlayers
        radius: ShellMetrics.radiusMedium
        color: previousPlayerHover.hovered
            ? Theme.surfaceBorderColor : Theme.selectedSurfaceColor

        Text {
            anchors.centerIn: parent
            text: Icons.previousMonth
            color: Theme.primaryTextColor
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: 16
        }

        HoverHandler {
            id: previousPlayerHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler { onTapped: mediaCard.switchPlayer(-1) }
    }

    Rectangle {
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            margins: 18
            rightMargin: 10
        }
        width: 30
        visible: mediaCard.multiplePlayers
        radius: ShellMetrics.radiusMedium
        color: nextPlayerHover.hovered
            ? Theme.surfaceBorderColor : Theme.selectedSurfaceColor

        Text {
            anchors.centerIn: parent
            text: Icons.nextMonth
            color: Theme.primaryTextColor
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: 16
        }

        HoverHandler {
            id: nextPlayerHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler { onTapped: mediaCard.switchPlayer(1) }
    }

    SequentialAnimation {
        id: playerSwitch

        property int direction: 1

        ParallelAnimation {
            NumberAnimation {
                target: mediaCard
                property: "switchOffset"
                to: -playerSwitch.direction * 28
                duration: 110
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: mediaCard
                property: "switchOpacity"
                to: 0
                duration: 110
                easing.type: Easing.InCubic
            }
        }
        ScriptAction {
            script: MediaService.selectRelative(playerSwitch.direction)
        }
        PropertyAction {
            target: mediaCard
            property: "switchOffset"
            value: playerSwitch.direction * 28
        }
        ParallelAnimation {
            NumberAnimation {
                target: mediaCard
                property: "switchOffset"
                to: 0
                duration: 170
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: mediaCard
                property: "switchOpacity"
                to: 1
                duration: 170
                easing.type: Easing.OutCubic
            }
        }
    }
}
