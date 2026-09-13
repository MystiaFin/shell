import QtQuick
import "../../components/state"
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
    visible: SettingsService.statusBarShowLogo
        || SettingsService.statusBarShowWorkspaces
        || SettingsService.statusBarShowWorkspaceName

    Row {
        id: content
        height: parent.height
        spacing: 10

        Item {
            visible: SettingsService.statusBarShowLogo
            width: visible ? 30 : 0
            height: 32

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1
                text: Icons.nixos
                color: Theme.accentColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 28
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: OverlayState.togglePowerMenu()
            }
        }

        WorkspaceStrip {
            visible: SettingsService.statusBarShowWorkspaces
            outputName: root.outputName
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            visible: SettingsService.statusBarShowWorkspaceName
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
}
