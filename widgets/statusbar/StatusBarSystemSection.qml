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
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 26
            radius: height / 2
            color: modeHover.hovered
                ? Theme.accentColor : Theme.selectedSurfaceColor
            border.width: 1
            border.color: Theme.accentColor

            Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: Theme.lightMode ? 0 : 0.5
                text: Theme.lightMode ? Icons.darkMode : Icons.lightMode
                color: modeHover.hovered
                    ? Theme.accentTextColor : Theme.accentColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 15
            }

            HoverHandler {
                id: modeHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler { onTapped: Theme.toggleColorMode() }
        }

        Rectangle {
            width: trayIcons.width + 20
            height: 26
            radius: height / 2
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
