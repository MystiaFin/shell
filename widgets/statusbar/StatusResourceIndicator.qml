import QtQuick
import "../../components/common"
import "../../components/theme"

Item {
    id: root

    property bool resourceAvailable: true
    required property real resourceValue
    required property color indicatorColor
    required property string iconText
    required property string iconFontFamily
    required property string outputText

    visible: resourceAvailable
    implicitWidth: content.width
    implicitHeight: 26

    Row {
        id: content

        height: parent.height
        spacing: 6

        Item {
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter

            StatusRing {
                anchors.fill: parent
                value: root.resourceValue
                ringColor: root.indicatorColor
            }

            Text {
                anchors.centerIn: parent
                text: root.iconText
                color: Theme.primaryTextColor
                font.family: root.iconFontFamily
                font.pixelSize: 10
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.outputText
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 14
            font.weight: Font.Light
        }
    }
}
