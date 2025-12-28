import QtQuick
import Quickshell

Item {
    id: comp

    property var service
    property var rootWindow
    
    property int itemHeight
    property int maxItems
    property int searchHeight
    property int spacing
    property int padding
    property int extraHeight

    signal requestHeightUpdate(int newHeight)

    anchors.fill: parent

    property int contentHeight: (Math.min(service.appModel.count, maxItems) * itemHeight) + searchHeight + spacing + (padding * 2) + extraHeight

    Rectangle {
        anchors.fill: parent
        color: "#11111b"
        radius: 16

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.radius
            color: parent.color
        }
    }

    // 2. The List Bubble (Top)
    Rectangle {
        id: listBackground
        
        opacity: service.appModel.count > 0 ? 1 : 0
        visible: opacity > 0
        
        anchors.bottom: searchBarBackground.top
        anchors.bottomMargin: spacing
        anchors.left: parent.left
        anchors.right: parent.right
        
        anchors.leftMargin: padding
        anchors.rightMargin: padding
        anchors.topMargin: padding
        
        height: comp.height - searchHeight - spacing - (padding * 2)

        color: "#1e1e2e"
        radius: 12
        clip: true

        Behavior on opacity { NumberAnimation { duration: 200 } }

        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 5
            
            clip: true
            model: service.appModel
            
            interactive: service.appModel.count > maxItems

            highlight: Rectangle {
                color: "#313244"
                radius: 8
            }

            delegate: Item {
                width: list.width
                height: itemHeight

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    spacing: 10

                    Item {
                        width: 24; height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Image {
                            anchors.fill: parent
                            source: "image://icon/" + model.id
                            visible: status === Image.Ready
                            asynchronous: true
                        }
                    }

                    Text {
                        text: model.name
                        color: ListView.isCurrentItem ? "#a6e3a1" : "#cdd6f4"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        service.runner.command = ["gtk-launch", model.id];
                        service.runner.running = true;
                        rootWindow.requestClose();
                    }
                }
            }
        }
    }

    // 3. The Search Bubble (Bottom)
    Rectangle {
        id: searchBarBackground
        height: searchHeight
        
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: padding
        
        color: "#1e1e2e"
        radius: 12

        TextInput {
            id: searchInput
            anchors.fill: parent
            anchors.margins: 15
            color: "#cdd6f4"
            font.pixelSize: 16
            verticalAlignment: Text.AlignVCenter
            activeFocusOnTab: true

            onTextChanged: service.rebuildList(text)
            Keys.onEscapePressed: rootWindow.requestClose()
            Keys.onDownPressed: list.incrementCurrentIndex()
            Keys.onUpPressed: list.decrementCurrentIndex()
            Keys.onReturnPressed: {
                if (service.appModel.count > 0) {
                    service.runner.command = ["gtk-launch", service.appModel.get(list.currentIndex).id];
                    service.runner.running = true;
                    rootWindow.requestClose();
                }
            }
        }
    }

    Connections {
        target: rootWindow
        function onVisibleChanged() {
            if (rootWindow.visible) {
                searchInput.text = "";
                searchInput.forceActiveFocus();
            } else {
                searchInput.focus = false;
            }
        }
    }
}
