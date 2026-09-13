import Quickshell
import Quickshell.Widgets
import QtQuick
import "../../components/common"
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property var result
    property bool selected: false

    signal activated

    Rectangle {
        anchors.fill: parent
        radius: ShellMetrics.radiusMedium
        color: Theme.hoverSurfaceColor
        opacity: hoverHandler.hovered && !root.selected ? 1 : 0

        Behavior on opacity {
            MotionAnimation {
                group: "launcher"
                type: MotionAnimation.FastEffects
            }
        }
    }

    IconImage {
        id: applicationIcon

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 12
        }

        implicitSize: 38
        visible: SettingsService.launcherShowIcons
            && root.result.type === "application"
        source: visible
            ? Quickshell.iconPath(root.result.application.icon,
                "application-x-executable") : ""
        asynchronous: true
    }

    Text {
        id: commandIcon

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 12
        }

        width: 38
        visible: SettingsService.launcherShowIcons
            && root.result.type === "command"
        text: visible ? root.result.icon : ""
        color: Theme.primaryTextColor
        font.family: Typography.nerdIconFontFamily
        font.pixelSize: 24
        horizontalAlignment: Text.AlignHCenter
    }

    Column {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: SettingsService.launcherShowIcons
                && (root.result.type === "application"
                    || root.result.type === "command") ? 62 : 12
            rightMargin: 12
        }
        spacing: SettingsService.launcherShowDescriptions ? 1 : 0

        Text {
            width: parent.width
            text: root.result.name
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 15
            font.weight: Font.Normal
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        Text {
            width: parent.width
            visible: SettingsService.launcherShowDescriptions
                && root.result.detail !== undefined
                && root.result.detail !== ""
            text: visible ? root.result.detail : ""
            color: Theme.mutedTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 10
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler { onTapped: root.activated() }
}
