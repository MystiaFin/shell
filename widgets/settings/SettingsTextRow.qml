import QtQuick
import "../../components/theme"

Item {
    id: root

    required property string title
    required property string detail
    required property string value
    property bool showSeparator: false
    signal valueRequested(string value)

    height: 104

    Column {
        anchors { left: parent.left; right: editor.left; verticalCenter: parent.verticalCenter; leftMargin: 20; rightMargin: 20 }
        spacing: 3
        Text {
            width: parent.width
            text: root.title
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 16
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
        Text {
            width: parent.width
            text: root.detail
            color: Theme.mutedTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 12
            elide: Text.ElideRight
        }
    }

    Rectangle {
        id: editor
        anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
        width: Math.min(280, root.width * 0.42)
        height: 42
        radius: ShellMetrics.radiusMedium
        color: Theme.selectedSurfaceColor

        TextInput {
            id: input
            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
            text: root.value
            color: Theme.primaryTextColor
            selectionColor: Theme.accentColor
            selectedTextColor: Theme.accentTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 12
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            onEditingFinished: {
                root.valueRequested(text);
                focus = false;
            }
        }
    }

    Rectangle {
        visible: root.showSeparator
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 20; rightMargin: 20 }
        height: 1
        color: Theme.surfaceBorderColor
        opacity: 0.65
    }
}
