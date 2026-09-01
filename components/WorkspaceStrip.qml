import QtQuick
import "../services"

Item {
    id: root

    required property string outputName

    readonly property var workspaces: NiriService.workspaces
        .filter(workspace => workspace.output === outputName)
        .sort((left, right) => left.idx - right.idx)
    readonly property int activePosition: {
        const position = workspaces.findIndex(workspace => workspace.is_active);
        return Math.max(0, position);
    }
    readonly property Item activeDelegate: workspaceRepeater.itemAt(activePosition)
    property int previousActivePosition: activePosition
    property real starRotation: 0

    implicitWidth: workspaceRow.width + 8
    implicitHeight: 32

    onActivePositionChanged: {
        const direction = activePosition >= previousActivePosition ? 1 : -1;
        starRotation += direction * 180;
        previousActivePosition = activePosition;
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.statusBarWorkspaceColor
    }

    Rectangle {
        id: highlight

        x: root.activeDelegate ? workspaceRow.x + root.activeDelegate.x : 4
        anchors.verticalCenter: parent.verticalCenter
        width: root.activeDelegate ? root.activeDelegate.width : 26
        height: 26
        radius: height / 2
        color: Theme.statusBarHighlightColor

        Text {
            anchors.centerIn: parent
            text: "󰫢"
            color: Theme.statusBarBackgroundColor
            font.family: "Symbols Nerd Font"
            font.pixelSize: 18
            rotation: root.starRotation

            Behavior on rotation {
                NumberAnimation {
                    duration: 700
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    Row {
        id: workspaceRow
        x: 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            id: workspaceRepeater
            model: root.workspaces

            Item {
                id: delegate

                required property var modelData

                width: 26
                height: 26

                Text {
                    anchors.centerIn: parent
                    visible: !delegate.modelData.is_active
                    text: ""
                    color: delegate.modelData.is_urgent
                            ? Theme.statusBarRedColor
                            : Theme.statusBarMutedColor
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 18
                    scale: 0.6

                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NiriService.focusWorkspace(delegate.modelData.idx)
                }
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
}
