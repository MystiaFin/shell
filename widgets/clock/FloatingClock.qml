import QtQuick
import "../../components/theme"

Item {
    id: root

    property date now: new Date()
    property int contentAlignment: Text.AlignHCenter

    Column {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 12
            rightMargin: 12
        }
        spacing: -4

        Text {
            width: parent.width
            text: Qt.formatTime(root.now, "hh:mm")
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 54
            font.weight: Font.Bold
            font.letterSpacing: 12
            horizontalAlignment: root.contentAlignment
        }

        Text {
            width: parent.width
            text: Qt.formatDate(root.now, "dddd, dd MMMM")
            color: Theme.secondaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 15
            font.weight: Font.Bold
            horizontalAlignment: root.contentAlignment
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
