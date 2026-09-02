import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../components/state"
import "../../components/theme"

PanelWindow {
    id: root

    required property var modelData
    readonly property var targetScreen: modelData

    property date now: new Date()

    screen: targetScreen
    color: "transparent"
    implicitHeight: ShellMetrics.statusBarHeight
    exclusiveZone: ShellMetrics.statusBarHeight

    anchors {
        top: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "status-bar"

    HoverHandler {
        onHoveredChanged: OverlayState.statusBarHovered = hovered
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.shellBackgroundColor
        topLeftRadius: 18
        topRightRadius: 18

        StatusBarWorkspaceSection {
            outputName: root.screen.name
            anchors {
                left: parent.left
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }
        }

        StatusBarCenterSection {
            currentTime: root.now
            anchors.centerIn: parent
        }

        StatusBarSystemSection {
            anchors {
                right: parent.right
                rightMargin: 15
                verticalCenter: parent.verticalCenter
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
