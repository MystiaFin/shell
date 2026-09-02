import QtQuick
import "../../components/state"
import "../../components/theme"

Item {
    id: root

    implicitWidth: content.width
    implicitHeight: 26

    Row {
        id: content

        height: parent.height
        spacing: 10

        BatteryIndicator { anchors.verticalCenter: parent.verticalCenter }
        CpuIndicator { anchors.verticalCenter: parent.verticalCenter }
        MemoryIndicator { anchors.verticalCenter: parent.verticalCenter }

        Rectangle {
            width: trayIcons.width + 20
            height: 26
            radius: 13
            color: Theme.accentColor

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: OverlayState.toggleUtilityCenter()
            }

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
                        color: Theme.shellBackgroundColor
                        font.family: Typography.nerdIconFontFamily
                        font.pixelSize: 15
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
