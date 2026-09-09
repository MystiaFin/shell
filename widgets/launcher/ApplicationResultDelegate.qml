import Quickshell
import Quickshell.Widgets
import QtQuick
import "../../components/theme"

Item {
    id: root

    required property var application

    signal hoverEntered()
    signal hoverExited()
    signal launchRequested()

    function launch(): void {
        launchRequested();
    }

    IconImage {
        id: applicationIcon

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 12
        }
        implicitSize: 38
        source: Quickshell.iconPath(root.application.icon,
            "application-x-executable")
        asynchronous: true
    }

    Text {
        anchors {
            left: applicationIcon.right
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 12
            rightMargin: 12
        }
        text: root.application.name
        color: Theme.primaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 15
        font.weight: Font.Normal
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    HoverHandler {
        id: resultHover

        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: {
            if (hovered)
                root.hoverEntered();
            else
                root.hoverExited();
        }
    }

    TapHandler {
        onTapped: root.launchRequested()
    }
}
