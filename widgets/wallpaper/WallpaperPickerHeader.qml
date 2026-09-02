import QtQuick
import QtQuick.Layouts
import "../../components/theme"

RowLayout {
    id: root

    required property int imageCount
    required property string directoryPath
    signal closeRequested()
    signal moveRequested()

    spacing: 12

    DragHandler {
        target: null
        onActiveChanged: if (active) root.moveRequested()
    }

    Rectangle {
        Layout.preferredWidth: 46
        Layout.preferredHeight: 46
        radius: 15
        color: Theme.accentColor

        Text {
            anchors.centerIn: parent
            text: Icons.wallpaper
            color: Theme.shellBackgroundColor
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: 22
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Text {
            text: "Wallpapers"
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 20
            font.weight: Font.Bold
        }

        Text {
            Layout.fillWidth: true
            text: root.imageCount + (root.imageCount === 1 ? " image" : " images")
                + " in " + root.directoryPath
            color: Theme.mutedTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 11
            elide: Text.ElideMiddle
        }
    }

    Rectangle {
        Layout.preferredWidth: 38
        Layout.preferredHeight: 38
        radius: 12
        color: closeHover.hovered
            ? Theme.dangerColor
            : Theme.panelSurfaceColor

        Text {
            anchors.centerIn: parent
            text: Icons.close
            color: closeHover.hovered
                ? Theme.shellBackgroundColor
                : Theme.primaryTextColor
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: 17
        }

        HoverHandler {
            id: closeHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler { onTapped: root.closeRequested() }
    }
}
