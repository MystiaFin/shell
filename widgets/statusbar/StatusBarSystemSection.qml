import QtQuick
import "../../components/state"
import "../../components/theme"
import "../../services"

Item {
    id: root

    implicitWidth: content.width
    implicitHeight: 26
    visible: SettingsService.statusBarShowBattery
        || SettingsService.statusBarShowMemory
        || SettingsService.statusBarShowTray

    Row {
        id: content
        height: parent.height
        spacing: 10

        BatteryIndicator {
            visible: SettingsService.statusBarShowBattery
            anchors.verticalCenter: parent.verticalCenter
        }
        MemoryIndicator {
            visible: SettingsService.statusBarShowMemory
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            visible: SettingsService.statusBarShowTray
            width: visible ? trayIcons.width + 20 : 0
            height: 26
            radius: height / 2
            color: Theme.accentColor

            HoverHandler { cursorShape: Qt.PointingHandCursor }
            TapHandler { onTapped: OverlayState.toggleUtilityCenter() }

            Row {
                id: trayIcons
                height: parent.height
                anchors.centerIn: parent
                spacing: 8

                Repeater {
                    model: [Icons.notifications, Icons.wifi, Icons.bluetooth]
                    Text {
                        required property string modelData
                        height: 26
                        text: modelData
                        color: Theme.accentTextColor
                        font.family: Typography.nerdIconFontFamily
                        font.pixelSize: 15
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
