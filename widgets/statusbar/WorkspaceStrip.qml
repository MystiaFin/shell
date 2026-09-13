import QtQuick
import "../../components/common"
import "../../components/theme"
import "../../services"

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
        color: Theme.selectedSurfaceColor
    }

    Rectangle {
        id: highlight

        x: workspaceRow.x + root.activePosition * (26 + workspaceRow.spacing)
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: height / 2
        color: Theme.accentHoverColor

        Text {
            anchors.centerIn: parent
            text: Icons.activeWorkspace
            color: Theme.accentTextColor
            font.family: Typography.symbolIconFontFamily
            font.pixelSize: 18
            rotation: root.starRotation

            Behavior on rotation {
                MotionAnimation { group: "statusBar"; type: MotionAnimation.SlowSpatial }
            }
        }

        Behavior on x {
            MotionAnimation { group: "statusBar"; type: MotionAnimation.FastSpatial }
        }

    }

    Row {
        id: workspaceRow
        x: 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: root.workspaces

            Item {
                id: delegate

                required property var modelData

                width: 26
                height: 26

                Text {
                    anchors.centerIn: parent
                    visible: !delegate.modelData.is_active
                    text: Icons.inactiveWorkspace
                    color: delegate.modelData.is_urgent
                            ? Theme.dangerColor
                            : Theme.mutedTextColor
                    font.family: Typography.symbolIconFontFamily
                    font.pixelSize: 18
                    scale: 0.6

                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NiriService.focusWorkspace(delegate.modelData.id)
                }
            }
        }
    }

    Behavior on implicitWidth {
        MotionAnimation { group: "statusBar"; type: MotionAnimation.FastSpatial }
    }
}
