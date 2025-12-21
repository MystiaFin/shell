import QtQuick

Item {
    id: liquidGroup
    width: 500
    height: 40
    z: 1

    Rectangle {
        id: bridge
        width: 700
        height: 20
        color: "#1e1e2e" // Must match background
        radius: 10
        anchors.top: parent.top
				anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        width: bridge.width - 2
        height: 5
        color: "#1e1e2e"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
