import QtQuick
import "../Services"
import "../Anim"

Row {
    id: root
    spacing: 15

    // Initialize Service
    WorkspaceService {
        id: wsService
    }

    // The Pill Container
    Rectangle {
        width: (wsService.model.count * 30) + 4
        height: 32
        radius: 16
        color: "#292c3c"
        anchors.verticalCenter: parent.verticalCenter

        // Smooth width adjustment when adding/removing workspaces
        Behavior on width { 
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic } 
        }

        // --- Active Indicator Animation ---
        WorkspaceAnim {
            anchors.verticalCenter: parent.verticalCenter
            targetIndex: wsService.activeIndex
            cellWidth: 30
            startOffset: 3
        }

        // --- Icons ---
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
                        
                        // Icon Scale Animation
                        Behavior on scale { 
                            NumberAnimation { duration: 150; easing.type: Easing.OutBack } 
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: wsService.focus(idx)
                    }
                }
            }
        }
    }

    // Window Title Text
    Text {
        text: wsService.activeWindowTitle
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
