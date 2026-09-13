import QtQuick
import "../../components/theme"

Rectangle {
    id: root

    property alias text: searchInput.text
    property alias focusTarget: searchInput

    property string placeholder: "Search applications..."

    signal moveSelectionRequested(bool down)
    signal accepted
    signal closeRequested

    height: 46
    radius: ShellMetrics.radiusMedium
    color: Theme.panelSurfaceColor

    TextInput {
        id: searchInput

        anchors {
            fill: parent
            leftMargin: 14
            rightMargin: 14
        }

        verticalAlignment: TextInput.AlignVCenter

        color: Theme.primaryTextColor
        selectionColor: Theme.selectedSurfaceColor
        selectedTextColor: Theme.primaryTextColor

        font.pixelSize: 15
        font.family: Typography.bodyFontFamily

        clip: true

        Keys.onDownPressed:
            root.moveSelectionRequested(true)

        Keys.onUpPressed:
            root.moveSelectionRequested(false)

        Keys.onReturnPressed:
            root.accepted()

        Keys.onEnterPressed:
            root.accepted()

        Keys.onEscapePressed:
            root.closeRequested()
    }

    Text {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 14
        }

        visible: root.text.length === 0
        text: root.placeholder

        color: Theme.mutedTextColor
        font.pixelSize: 15
        font.family: Typography.bodyFontFamily
    }
}
