import QtQuick
import "../theme"

Rectangle {
    id: root

    property bool checked: false
    signal toggled()

    implicitWidth: 42
    implicitHeight: 24
    radius: height / 2
    color: checked ? Theme.accentColor : Theme.surfaceBorderColor

    Rectangle {
        width: 20
        height: 20
        radius: width / 2
        y: 2
        x: root.checked ? root.width - width - 2 : 2
        color: Theme.primaryTextColor

        Behavior on x {
            NumberAnimation {
                duration: ShellMetrics.fastAnimationMs
                easing.type: Easing.OutCubic
            }
        }
    }

    HoverHandler { cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: root.toggled() }
}
