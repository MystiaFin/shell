import QtQuick
import "../../components/common"
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property string outputName

    readonly property string style: SettingsService.workspaceIndicatorStyle
    readonly property var workspaces: NiriService.workspaces
        .filter(workspace => workspace.output === outputName)
        .sort((left, right) => left.idx - right.idx)
    readonly property int activePosition: {
        const position = workspaces.findIndex(workspace => workspace.is_active);
        return Math.max(0, position);
    }
    readonly property real itemWidth: style === "dots" ? 18 : 26
    property int previousActivePosition: activePosition
    property real starRotation: 0

    implicitWidth: workspaceRow.width + (style === "pill" ? 8 : 0)
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
        visible: root.style === "pill"
    }

    Rectangle {
        id: highlight
        visible: root.style === "pill" && root.workspaces.length > 0
        x: workspaceRow.x + root.activePosition * (root.itemWidth + workspaceRow.spacing)
        anchors.verticalCenter: parent.verticalCenter
        width: root.itemWidth
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
        x: root.style === "pill" ? 4 : 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.style === "dots" ? 2 : 4

        Repeater {
            model: root.workspaces

            Item {
                id: delegate
                required property var modelData
                width: root.itemWidth
                height: 26

                Text {
                    anchors.centerIn: parent
                    visible: root.style === "pill" && !delegate.modelData.is_active
                    text: Icons.inactiveWorkspace
                    color: delegate.modelData.is_urgent ? Theme.dangerColor : Theme.mutedTextColor
                    font.family: Typography.symbolIconFontFamily
                    font.pixelSize: 18
                    scale: 0.6
                }

                Rectangle {
                    anchors.centerIn: parent
                    visible: root.style === "dots"
                    width: delegate.modelData.is_active ? 10 : 6
                    height: width
                    radius: width / 2
                    color: delegate.modelData.is_urgent
                        ? Theme.dangerColor
                        : delegate.modelData.is_active ? Theme.accentColor : Theme.mutedTextColor

                    Behavior on width { MotionAnimation { group: "statusBar"; type: MotionAnimation.FastSpatial } }
                }

                Rectangle {
                    anchors.centerIn: parent
                    visible: root.style === "numbers"
                    width: 24
                    height: 24
                    radius: ShellMetrics.radiusSmall
                    color: delegate.modelData.is_active ? Theme.selectedSurfaceColor : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: delegate.modelData.idx
                        color: delegate.modelData.is_urgent
                            ? Theme.dangerColor
                            : delegate.modelData.is_active ? Theme.accentColor : Theme.mutedTextColor
                        font.family: Typography.bodyFontFamily
                        font.pixelSize: 11
                        font.weight: delegate.modelData.is_active ? Font.DemiBold : Font.Normal
                    }
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
