import QtQuick
import Quickshell.Io

Text {
    id: root
    text: "⏻"
    color: "#f38ba8"
    font.pixelSize: 28

    Process {
        id: wlogoutProcess
        command: ["wlogout"]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: wlogoutProcess.running = true
    }
}
