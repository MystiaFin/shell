import QtQuick

Rectangle {
    id: button
    
    property string icon: ""
    property color buttonColor: "#89b4fa"
    property color iconColor: "#1e1e2e"
    property bool active: false
    
    signal clicked()
    
    width: 54
    height: 54
    radius: 18
    color: active ? buttonColor : "#313244"
    
    Behavior on color {
        ColorAnimation {
            duration: 200
        }
    }
    
    Text {
        anchors.centerIn: parent
        text: button.icon
        color: active ? button.iconColor : "#cdd6f4"
        font.pixelSize: 20
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
        
        onPressed: button.scale = 0.95
        onReleased: button.scale = 1.0
    }
    
    Behavior on scale {
        NumberAnimation {
            duration: 100
        }
    }
}
