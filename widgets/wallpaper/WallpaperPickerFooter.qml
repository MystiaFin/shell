import QtQuick
import QtQuick.Layouts
import "../../components/theme"

RowLayout {
    id: root

    required property bool hasPendingSelection
    signal applyRequested()

    spacing: 12

    Text {
        Layout.fillWidth: true
        text: root.hasPendingSelection
            ? "Ready to apply selected wallpaper"
            : "Current wallpaper selected"
        color: root.hasPendingSelection
            ? Theme.accentColor
            : Theme.mutedTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 11
        font.weight: Font.DemiBold
    }

    Rectangle {
        Layout.preferredWidth: 108
        Layout.preferredHeight: 42
        radius: 13
        color: root.hasPendingSelection
            ? applyHover.hovered
                ? Theme.accentHoverColor
                : Theme.accentColor
            : Theme.surfaceBorderColor

        Text {
            anchors.centerIn: parent
            text: "Apply"
            color: root.hasPendingSelection
                ? Theme.shellBackgroundColor
                : Theme.mutedTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 12
            font.weight: Font.Bold
        }

        HoverHandler {
            id: applyHover
            enabled: root.hasPendingSelection
            cursorShape: root.hasPendingSelection
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor
        }
        TapHandler {
            enabled: root.hasPendingSelection
            onTapped: root.applyRequested()
        }
    }
}
