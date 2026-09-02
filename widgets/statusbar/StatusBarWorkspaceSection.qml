import Quickshell.Io
import QtQuick
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property string outputName

    readonly property var outputWorkspaces: NiriService.workspaces
        .filter(workspace => workspace.output === outputName)
    readonly property var activeWorkspace: outputWorkspaces
        .find(workspace => workspace.is_active)

    implicitWidth: content.width
    implicitHeight: 32

    Row {
        id: content

        height: parent.height
        spacing: 10

        Item {
            width: 18
            height: 32

            Text {
                anchors.centerIn: parent
                text: Icons.power
                color: Theme.dangerColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 16
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: logoutProcess.running = true
            }
        }

        WorkspaceStrip {
            outputName: root.outputName
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            height: 26
            anchors.verticalCenter: parent.verticalCenter
            text: root.activeWorkspace
                ? root.activeWorkspace.name
                    && root.activeWorkspace.name !== root.activeWorkspace.idx.toString()
                        ? root.activeWorkspace.name
                        : "Workspace " + root.activeWorkspace.idx
                : "Desktop"
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 14
            font.weight: Font.Medium
            verticalAlignment: Text.AlignVCenter
        }
    }

    Process {
        id: logoutProcess
        command: ["wlogout"]
    }
}
