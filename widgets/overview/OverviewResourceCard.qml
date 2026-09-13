import QtQuick
import "../../components/common"
import "../../components/theme"

Item {
    id: root

    required property Item wallpaperSourceItem
    required property rect wallpaperRect
    required property string label
    property string icon: ""
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

    Item {
        anchors {
            fill: parent
            margins: 18
        }

        Text {
            id: labelText

            anchors.top: parent.top
            width: parent.width
            text: root.label
            color: Theme.secondaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 13
            font.weight: Font.DemiBold
            horizontalAlignment: root.contentAlignment
        }

        Text {
            anchors {
                top: labelText.bottom
                topMargin: 2
            }
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

        Rectangle {
            id: progressBar

            anchors.bottom: parent.bottom
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
                    MotionAnimation { type: MotionAnimation.FastSpatial }
                }
            }
        }

        Item {
            anchors {
                left: parent.left
                right: parent.right
                bottom: progressBar.top
                bottomMargin: 6
            }
            height: 38

            Text {
                id: iconText

                anchors {
                    left: root.contentAlignment === Text.AlignLeft
                        ? parent.left : undefined
                    right: root.contentAlignment === Text.AlignRight
                        ? parent.right : undefined
                    verticalCenter: parent.verticalCenter
                }
                visible: root.icon !== ""
                text: root.icon
                color: Theme.secondaryTextColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 28
                horizontalAlignment: root.contentAlignment
            }

            Text {
                anchors {
                    left: root.contentAlignment === Text.AlignRight
                        ? parent.left : iconText.right
                    right: root.contentAlignment === Text.AlignLeft
                        ? parent.right : iconText.left
                    leftMargin: root.contentAlignment === Text.AlignLeft
                        && iconText.visible ? 10 : 0
                    rightMargin: root.contentAlignment === Text.AlignRight
                        && iconText.visible ? 10 : 0
                    verticalCenter: parent.verticalCenter
                }
                text: root.value
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 34
                font.weight: Font.Bold
                horizontalAlignment: root.contentAlignment === Text.AlignLeft
                    ? Text.AlignRight : Text.AlignLeft
            }
        }
    }
}
