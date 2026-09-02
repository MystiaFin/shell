import QtQuick
import "../../components/theme"

Item {
    id: root

    required property url source
    required property string name
    required property bool selected
    signal selectionRequested()

    Rectangle {
        anchors {
            fill: parent
            margins: 5
        }
        radius: 14
        color: cardHover.hovered
            ? Theme.surfaceBorderColor
            : Theme.selectedSurfaceColor
        border.width: root.selected ? 3 : 0
        border.color: Theme.accentColor
        clip: true

        Image {
            anchors {
                fill: parent
                bottomMargin: 30
            }
            source: root.source
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            mipmap: true
        }

        Rectangle {
            anchors {
                right: parent.right
                bottom: parent.bottom
                left: parent.left
            }
            height: 30
            color: Theme.selectedSurfaceColor

            Text {
                anchors {
                    fill: parent
                    rightMargin: 9
                    leftMargin: 9
                }
                text: root.name
                verticalAlignment: Text.AlignVCenter
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 10
                font.weight: Font.DemiBold
                elide: Text.ElideMiddle
            }
        }

        Rectangle {
            visible: root.selected
            anchors {
                top: parent.top
                right: parent.right
                margins: 9
            }
            width: 25
            height: 25
            radius: 9
            color: Theme.accentColor

            Text {
                anchors.centerIn: parent
                text: Icons.confirm
                color: Theme.shellBackgroundColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 13
            }
        }

        HoverHandler {
            id: cardHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler { onTapped: root.selectionRequested() }
    }
}
