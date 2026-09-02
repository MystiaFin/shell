import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../components/theme"

Rectangle {
    id: root

    required property var modelData
    readonly property var device: modelData
    readonly property string displayName: device.name || device.deviceName || "Unknown device"
    readonly property string statusText: {
        if (device.connected)
            return "Connected";
        if (device.pairing)
            return "Pairing…";
        return device.paired ? "Paired" : "Available";
    }
    readonly property string deviceIconSource: device.icon
        ? Quickshell.iconPath(device.icon)
        : ""

    signal activationRequested(var device)
    signal forgetRequested(var device)

    height: 54
    radius: 12
    color: device.connected ? Theme.selectedSurfaceColor : Theme.panelSurfaceColor

    RowLayout {
        anchors {
            fill: parent
            margins: 9
        }
        spacing: 9

        Rectangle {
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            radius: 10
            color: Theme.selectedSurfaceColor

            Image {
                id: deviceImage

                anchors.fill: parent
                anchors.margins: 7
                source: root.deviceIconSource
                visible: source !== ""
            }

            Text {
                anchors.centerIn: parent
                visible: !deviceImage.visible
                text: Icons.bluetooth
                color: Theme.accentColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 16
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.displayName
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 12
                font.weight: root.device.connected ? Font.DemiBold : Font.Normal
                elide: Text.ElideRight
            }

            Text {
                text: root.statusText
                color: root.device.connected ? Theme.successColor : Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 9
            }
        }

        Text {
            visible: root.device.batteryAvailable
            text: Math.round(root.device.battery * 100) + "%"
            color: Theme.mutedTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 9
        }

        Text {
            visible: root.device.paired
            text: Icons.close
            color: forgetHover.hovered ? Theme.dangerColor : Theme.mutedTextColor
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: 13

            HoverHandler {
                id: forgetHover
                cursorShape: Qt.PointingHandCursor
            }
            TapHandler {
                gesturePolicy: TapHandler.ReleaseWithinBounds
                onTapped: root.forgetRequested(root.device)
            }
        }
    }

    HoverHandler { cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: root.activationRequested(root.device) }
}
