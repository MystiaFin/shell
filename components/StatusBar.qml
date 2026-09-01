import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../services"

PanelWindow {
    id: root

    required property var modelData

    property date now: new Date()
    readonly property var screenWorkspaces: NiriService.workspaces
        .filter(workspace => workspace.output === root.screen.name)
    readonly property var activeWorkspace: screenWorkspaces.find(workspace => workspace.is_active)

    function toggleControlCenter(): void {
        UtilityCenterState.hide();
        ControlCenterState.toggle();
    }

    function toggleUtilityCenter(): void {
        ControlCenterState.hide();
        UtilityCenterState.toggle();
    }

    screen: modelData
    color: "transparent"
    implicitHeight: 40
    exclusiveZone: 40

    anchors {
        top: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "status-bar"

    HoverHandler {
        onHoveredChanged: {
            ControlCenterState.statusBarHovered = hovered;
            UtilityCenterState.statusBarHovered = hovered;
        }
    }

    component BarText: Text {
        height: 26
        color: Theme.statusBarTextColor
        font.family: "Poppins"
        font.pixelSize: 14
        font.weight: Font.Light
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.statusBarBackgroundColor
        topLeftRadius: 18
        topRightRadius: 18

        Row {
            height: 32
            anchors {
                left: parent.left
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }
            spacing: 10

            Item {
                width: 18
                height: 32

                Text {
                    anchors.centerIn: parent
                    text: "⏻"
                    color: Theme.statusBarRedColor
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 16
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: logoutProcess.running = true
                }
            }

            WorkspaceStrip {
                outputName: root.screen.name
                anchors.verticalCenter: parent.verticalCenter
            }

            BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.activeWorkspace
                    ? root.activeWorkspace.name
                        && root.activeWorkspace.name !== root.activeWorkspace.idx.toString()
                            ? root.activeWorkspace.name
                            : "Workspace " + root.activeWorkspace.idx
                    : "Desktop"
                font.weight: Font.Medium
            }
        }

        Row {
            height: 26
            anchors.centerIn: parent
            spacing: 2

            Rectangle {
                id: audioModule

                width: controls.width + 16
                height: 26
                radius: 13
                color: Theme.statusBarSurfaceColor

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                MouseArea {
                    anchors.fill: parent
                    z: -1
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleControlCenter()
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
                            ? Theme.statusBarMutedColor
                            : Theme.statusBarAccentColor
                        onClicked: root.toggleControlCenter()
                        onScrolled: delta => AudioService.setVolume(AudioService.volume + delta)
                    }

                    StatusRing {
                        width: 18
                        height: 18
                        anchors.verticalCenter: parent.verticalCenter
                        value: AudioService.microphoneVolume
                        ringWidth: 4
                        ringColor: AudioService.microphoneMuted
                            ? Theme.statusBarMutedColor
                            : Theme.statusBarAccentColor
                        onClicked: root.toggleControlCenter()
                        onScrolled: delta => AudioService.setMicrophoneVolume(
                            AudioService.microphoneVolume + delta)
                    }
                }
            }

            Rectangle {
                width: mediaRow.width + 20
                height: 26
                radius: 13
                color: Theme.statusBarSurfaceColor

                Row {
                    id: mediaRow
                    height: parent.height
                    anchors.centerIn: parent
                    spacing: 7

                    Text {
                        height: parent.height
                        text: "󰎈"
                        color: Theme.statusBarGreenColor
                        font.family: "JetBrains Mono Nerd Font"
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
                text: Qt.formatTime(root.now, "hh:mm AP") + "  •  "
                    + Qt.formatDate(root.now, "dddd, dd MMM yyyy")
                font.pixelSize: 15
            }
        }

        Row {
            height: 26
            anchors {
                right: parent.right
                rightMargin: 15
                verticalCenter: parent.verticalCenter
            }
            spacing: 10

            BatteryIndicator { anchors.verticalCenter: parent.verticalCenter }
            CpuIndicator { anchors.verticalCenter: parent.verticalCenter }
            MemoryIndicator { anchors.verticalCenter: parent.verticalCenter }

            Rectangle {
                width: trayIcons.width + 20
                height: 26
                radius: 13
                color: Theme.statusBarAccentColor

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: root.toggleUtilityCenter()
                }

                Row {
                    id: trayIcons
                    height: parent.height
                    anchors.centerIn: parent
                    spacing: 8

                    Repeater {
                        model: ["󰂚", "󰖩", "󰂯"]

                        Text {
                            required property string modelData

                            height: 26
                            text: modelData
                            color: Theme.statusBarBackgroundColor
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 15
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }

    Process {
        id: logoutProcess
        command: ["wlogout"]
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
