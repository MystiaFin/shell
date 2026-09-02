import QtQuick
import QtQuick.Layouts
import "../../components/theme"

RowLayout {
    id: root

    required property string currentPage

    signal pageRequested(string page)
    signal wallpaperRequested()

    spacing: 8

    Item { Layout.preferredWidth: 42 }
    Item { Layout.fillWidth: true }

    Repeater {
        model: [
            { page: "notifications", icon: Icons.notifications },
            { page: "wifi", icon: Icons.wifi },
            { page: "bluetooth", icon: Icons.bluetooth }
        ]

        Rectangle {
            id: tabButton

            required property var modelData
            readonly property bool active: root.currentPage === modelData.page

            Layout.preferredWidth: 44
            Layout.preferredHeight: 38
            radius: 13
            color: active
                ? Theme.accentColor
                : tabHover.hovered
                    ? Theme.surfaceBorderColor
                    : Theme.panelSurfaceColor

            Text {
                anchors.centerIn: parent
                text: tabButton.modelData.icon
                color: tabButton.active
                    ? Theme.shellBackgroundColor
                    : Theme.primaryTextColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 18
            }

            HoverHandler {
                id: tabHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: root.pageRequested(tabButton.modelData.page)
            }
        }
    }

    Item { Layout.fillWidth: true }

    Rectangle {
        Layout.preferredWidth: 42
        Layout.preferredHeight: 38
        radius: 13
        color: wallpaperHover.hovered
            ? Theme.accentColor
            : Theme.selectedSurfaceColor
        border.width: 1
        border.color: Theme.accentColor

        Text {
            anchors.centerIn: parent
            text: Icons.wallpaper
            color: wallpaperHover.hovered
                ? Theme.shellBackgroundColor
                : Theme.accentColor
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: 19
        }

        HoverHandler {
            id: wallpaperHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler { onTapped: root.wallpaperRequested() }
    }
}
