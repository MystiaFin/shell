import QtQuick
import "../../components/theme"

Rectangle {
    id: root

    width: parent ? parent.width : 0
    height: 116
    radius: ShellMetrics.radiusExtraLarge
    color: Theme.panelSurfaceColor

    Row {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 20
            rightMargin: 20
        }
        spacing: 12

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - swatches.width - 12
            spacing: 3
            Text {
                width: parent.width
                text: "Current palette"
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 16
                font.weight: Font.DemiBold
            }
            Text {
                width: parent.width
                text: "Live preview of the colors currently used by the shell"
                color: Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
        }

        Row {
            id: swatches
            anchors.verticalCenter: parent.verticalCenter
            spacing: 7

            Repeater {
                model: [
                    Theme.shellBackgroundColor,
                    Theme.panelSurfaceColor,
                    Theme.selectedSurfaceColor,
                    Theme.accentColor,
                    Theme.successColor,
                    Theme.dangerColor
                ]

                Rectangle {
                    required property color modelData
                    width: 28
                    height: 44
                    radius: ShellMetrics.radiusSmall
                    color: modelData
                    border.width: 1
                    border.color: Theme.surfaceBorderColor
                }
            }
        }
    }
}
