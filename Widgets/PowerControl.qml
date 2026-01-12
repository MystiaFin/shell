import QtQuick
import Quickshell

PanelWindow {
    height: container.height
    implicitWidth: 140
    color: "transparent"

    anchors {
        top: true
        left: true
    }
    margins {
        top: 44
        left: 4
    }
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
        id: container
        width: parent.width
        height: menuList.contentHeight + 10

        color: "#1e1e2e"
        radius: 12
        border.width: 1
        border.color: "#313244"

        ListView {
            id: menuList
            anchors.fill: parent
            anchors.margins: 5
            interactive: false

            model: ["⏻ Shutdown", "Reboot", "Lock", "Suspend", "Hibernate", "Logout"]

            delegate: Rectangle {
                width: ListView.view.width
                height: 30
                radius: 6
                color: "transparent"

                Text {
                    text: modelData
                    color: "white"
                    anchors.centerIn: parent
                    font.pixelSize: 14
                    font.family: "Poppins"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#45475a"
                    onExited: parent.color = "transparent"
                    onClicked: console.log("Clicked " + modelData)
                }
            }
        }
    }
}
