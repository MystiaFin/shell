import QtQuick
import "../Services"

FocusScope {
    id: searchScope
    width: parent.width
    height: 50
    
    property alias text: textInput.text
    
    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 8
        border.color: "#313244"
        border.width: 1

        TextInput {
            id: textInput
            anchors.fill: parent
            anchors.margins: 15
            color: "white"
            font.pixelSize: 16
            verticalAlignment: TextInput.AlignVCenter
            
            focus: true
            
            onTextChanged: {
                LauncherService.searchText = text
            }
            
            Text {
                anchors.fill: parent
                text: "Search applications..."
                color: "#666666"
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
                visible: textInput.text.length === 0
            }
        }
    }
}
