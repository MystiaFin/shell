import QtQuick
import QtQuick.Layouts
import "../../components/common"
import "../../components/theme"

Rectangle {
    id: root

    required property string icon
    required property string title
    required property string statusText
    required property bool active
    property bool toggleEnabled: true
    property color statusColor: Theme.mutedTextColor

    signal toggleRequested()

    Layout.fillWidth: true
    Layout.preferredHeight: 58
    radius: 14
    color: Theme.panelSurfaceColor

    RowLayout {
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: 12
            color: root.active ? Theme.accentColor : Theme.surfaceBorderColor

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: Theme.shellBackgroundColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 18
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                text: root.title
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                text: root.statusText
                color: root.statusColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 10
                elide: Text.ElideRight
            }
        }

        UtilitySwitch {
            enabled: root.toggleEnabled
            checked: root.active
            onToggled: root.toggleRequested()
        }
    }
}
