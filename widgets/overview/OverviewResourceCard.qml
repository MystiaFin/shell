import QtQuick
import "../../components/theme"

Item {
    id: root

    required property Item wallpaperSourceItem
    required property rect wallpaperRect
    required property string label
    required property string value
    required property string detail
    required property real progress
    required property color accentColor

    readonly property int contentAlignment:
        wallpaperRect.x + wallpaperRect.width / 2
            < wallpaperSourceItem.width / 2
        ? Text.AlignLeft : Text.AlignRight

    OverviewCardBackground {
        anchors.fill: parent
        wallpaperSourceItem: root.wallpaperSourceItem
        wallpaperRect: root.wallpaperRect
    }

    Column {
        anchors {
            fill: parent
            margins: 18
        }
        spacing: 4

        Text {
            width: parent.width
            text: root.label
            color: Theme.secondaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 13
            font.weight: Font.DemiBold
            horizontalAlignment: root.contentAlignment
        }

        Text {
            width: parent.width
            height: 14
            opacity: root.detail !== "" ? 1 : 0
            text: root.detail
            color: Theme.mutedTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 11
            elide: Text.ElideRight
            horizontalAlignment: root.contentAlignment
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            width: parent.width
            text: root.value
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 34
            font.weight: Font.Bold
            horizontalAlignment: root.contentAlignment
        }

        Rectangle {
            width: parent.width
            height: 5
            radius: height / 2
            color: Theme.surfaceBorderColor

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.progress))
                height: parent.height
                radius: parent.radius
                color: root.accentColor

                Behavior on width {
                    NumberAnimation {
                        duration: ShellMetrics.pageTransitionDurationMs
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
