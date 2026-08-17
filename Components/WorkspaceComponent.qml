import QtQuick
import Quickshell.Io
import "../Services"
import "../Anim"

Row {
    id: root
    spacing: 15

    property int lastActiveIndex: 0
    property int spinDirection: 1

    WorkspaceService { 
        id: wsService 
        
        onActiveIndexChanged: {
            if (wsService.activeIndex > root.lastActiveIndex) {
                root.spinDirection = 1
            } else {
                root.spinDirection = -1
            }
            root.lastActiveIndex = wsService.activeIndex
        }
    }

    Process {
        id: niriCommand
        command: [] 
    }

    Rectangle {
        width: (wsService.model.count * 30) + 4
        height: 32
        radius: 16
        color: "#292c3c"
        anchors.verticalCenter: parent.verticalCenter

        Behavior on width {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        WorkspaceAnim {
            anchors.verticalCenter: parent.verticalCenter
            targetIndex: wsService.activeIndex
            cellWidth: 30
            startOffset: 3
        }

        Row {
            id: workspaceRow
            anchors.fill: parent
            anchors.leftMargin: 3
            spacing: 4

            Repeater {
                model: wsService.model

                Rectangle {
                    width: 26
                    height: 26
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                        text: active ? "󰫢" : ""
                        color: active ? "#1e1e2e" : "#585b70"

                        scale: active ? 1.0 : 0.6
                        Behavior on scale { NumberAnimation { duration: 150 } }

                        rotation: active ? (root.spinDirection * 180) : 0
                        
                        Behavior on rotation {
                            NumberAnimation {
                                duration: 700
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            niriCommand.running = false
                            niriCommand.command = ["niri", "msg", "action", "focus-workspace", model.idx]
                            niriCommand.running = true
                        }
                    }
                }
            }
        }
    }

    Text {
        text: "Workspace " + (wsService.activeIndex + 1)
        font.pixelSize: 14
        font.family: "Poppins"
        font.weight: Font.Medium
        color: "#CDD6F4"
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
        maximumLineCount: 1
        width: 300
    }
}
