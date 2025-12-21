import QtQuick
import Quickshell

Rectangle {
    id: container
    
    required property var service
    required property var rootWindow

    width: 500
    height: col.height + 30

    color: "#1e1e2e"
    radius: 8

    function launchCurrent() {
        var item = service.displayModel.get(appList.currentIndex);
        if (item) {
            service.launch(item.launchId);
            rootWindow.visible = false;
        }
    }

    MouseArea {
        anchors.fill: parent
    }

    Column {
        id: col
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 15
        spacing: 10

        ListView {
            id: appList
            width: parent.width

            property int calculatedHeight: service.displayModel.count * 40
            height: Math.min(calculatedHeight, 320)

            Behavior on height {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutQuad
                }
            }
            visible: service.displayModel.count > 0

            clip: true
            model: service.displayModel

            highlight: Rectangle {
                color: "#313244"
                radius: 4
            }
            highlightMoveDuration: 0

            delegate: Item {
                width: appList.width
                height: 40

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: appList.currentIndex = index
                    onClicked: launchCurrent()
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    spacing: 10

                    Image {
                        id: iconImg
                        source: "image://icon/" + model.launchId
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                        onStatusChanged: if (iconImg.status === Image.Error)
                            iconImg.source = "image://icon/application-x-executable"
                    }

                    Text {
                        text: model.displayName
                        color: ListView.isCurrentItem ? "#a6e3a1" : "#cdd6f4"
                        font.bold: ListView.isCurrentItem
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // SEARCH BAR
        Rectangle {
            width: parent.width
            height: 50
            color: "#181825"
            radius: 4

            TextInput {
                id: input
                anchors.fill: parent
                anchors.margins: 12
                color: "white"
                font.pixelSize: 18
                verticalAlignment: Text.AlignVCenter
                focus: true
                Component.onCompleted: forceActiveFocus()

                // Link to Service
                onTextChanged: service.searchText = text

                Keys.onDownPressed: appList.incrementCurrentIndex()
                Keys.onUpPressed: appList.decrementCurrentIndex()
                Keys.onReturnPressed: launchCurrent()
                Keys.onEscapePressed: rootWindow.visible = false
            }
        }
    }
}
