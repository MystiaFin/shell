import Quickshell
import Quickshell.Widgets
import QtQuick
import "../../components/theme"

Item {
    id: root

    required property var application
    required property bool selected

    signal hoverRequested()
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
        font.weight: root.selected ? Font.DemiBold : Font.Normal
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hoverRequested()
        onClicked: root.launchRequested()
    }
}
