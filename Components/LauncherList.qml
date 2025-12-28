import QtQuick
import "../Anim"

Rectangle {
    id: root

    property var service
    property var rootWindow
    property var anchorTarget
    property int itemHeight
    property int maxItems
    property int spacing
    property int padding
    property int containerHeight
    property int searchHeight

    property alias view: list

    anchors.bottom: anchorTarget.top
    anchors.bottomMargin: spacing
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: padding
    anchors.rightMargin: padding
    anchors.topMargin: padding

    height: containerHeight - searchHeight - spacing - (padding * 2)

    color: "#1e1e2e"
    radius: 12
    clip: true

    opacity: service.appModel.count > 0 ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        LauncherAnim {
            duration: 200
        }
    }

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
                    width: 24
                    height: 24
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
                    model.entry.execute();
                    rootWindow.requestClose();
                }
            }
        }
    }
}
