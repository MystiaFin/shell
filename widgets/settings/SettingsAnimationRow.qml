import QtQuick
import "../../components/common"
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property string groupKey
    required property string title
    required property string detail
    property bool showSeparator: false

    readonly property string styleKey: groupKey + "Animation"
    readonly property string durationKey: groupKey + "Duration"

    height: 78

    Column {
        anchors {
            left: parent.left
            right: controls.left
            verticalCenter: parent.verticalCenter
            leftMargin: 18
            rightMargin: 18
        }
        spacing: 2

        Text {
            width: parent.width
            text: root.title
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 13
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: root.detail
            color: Theme.mutedTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 10
            elide: Text.ElideRight
        }
    }

    Row {
        id: controls

        anchors {
            right: parent.right
            rightMargin: 16
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        SettingsSmallButton {
            width: 84
            label: SettingsService[root.styleKey]
            emphasized: true
            onClicked: {
                const styles = ["off", "fade", "spatial", "spring"];
                const current = styles.indexOf(SettingsService[root.styleKey]);
                SettingsService.setValue(
                    root.styleKey,
                    styles[(current + 1) % styles.length]);
            }
        }

        Rectangle {
            width: 136
            height: 34
            radius: ShellMetrics.radiusMedium
            color: Theme.selectedSurfaceColor

            SettingsSmallButton {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 2
                }
                width: 32
                height: 30
                label: "−"
                transparent: true
                onClicked: SettingsService.setValue(
                    root.durationKey,
                    Math.max(0, SettingsService[root.durationKey] - 50))
            }

            Text {
                anchors.centerIn: parent
                width: 68
                text: SettingsService[root.durationKey] + " ms"
                color: Theme.secondaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 10
                horizontalAlignment: Text.AlignHCenter
            }

            SettingsSmallButton {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: 2
                }
                width: 32
                height: 30
                label: "+"
                transparent: true
                onClicked: SettingsService.setValue(
                    root.durationKey,
                    Math.min(5000, SettingsService[root.durationKey] + 50))
            }
        }
    }

    Rectangle {
        visible: root.showSeparator
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 18
            rightMargin: 18
        }
        height: 1
        color: Theme.surfaceBorderColor
        opacity: 0.65
    }
}
