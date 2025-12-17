import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../Components"

PanelWindow {
    id: panel
    property color bgColor: "#1E1E2E"
    property color surfaceColor: "#313244"
    property color textColor: "#cdd6f4"

    anchors {
        top: true
        left: true
        right: true
    }

    height: 40
    color: bgColor

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: 40

    Process {
        id: wlogoutProcess
        command: ["wlogout"]
    }

    // --- Left Side ---
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        PowerButton {
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 4
        }

        WorkspaceComponent {
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // --- Center Area ---
    Row {
        anchors.centerIn: parent
        spacing: 2

        ControlPanelButton {
            surfaceColor: panel.surfaceColor
        }
        MprisComponent {
            id: mediaStatus
        }
				TimeComponent {}
    }

    // --- Right Side ---
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 15
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Rectangle {
            width: iconsRow.width + 20
            height: 26
            radius: 13
            color: "#ef9f76"

            Row {
                id: iconsRow
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "󰂯"
                    color: "#303446"
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "󰖩"
                    color: "#303446"
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "󰂚"
                    color: "#303446"
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
