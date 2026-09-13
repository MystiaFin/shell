import Quickshell
import Quickshell.Widgets
import QtQuick
import "../../components/common"
import "../../components/theme"

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

        visible: root.result.type === "application"

        source: root.result.type === "application"
            ? Quickshell.iconPath(
                root.result.application.icon,
                "application-x-executable"
            )
            : ""

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

        visible: root.result.type === "command"
        text: visible ? root.result.icon : ""

        color: Theme.primaryTextColor
        font.family: Typography.nerdIconFontFamily
        font.pixelSize: 24
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        anchors {
            left: {
                if (root.result.type === "application")
                    return applicationIcon.right;

                if (root.result.type === "command")
                    return commandIcon.right;

                return parent.left;
            }

            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 12
            rightMargin: 12
        }

        text: root.result.name
        color: Theme.primaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 15
        font.weight: Font.Normal
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.activated()
    }
}
