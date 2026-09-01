import QtQuick

Rectangle {
    id: root

    property bool checked: false
    signal toggled()

    implicitWidth: 42
    implicitHeight: 24
    radius: height / 2
    color: checked ? Theme.statusBarBlueColor : Theme.statusBarSurfaceBorderColor

    Rectangle {
        width: 20
        height: 20
        radius: width / 2
        y: 2
        x: root.checked ? root.width - width - 2 : 2
        color: Theme.statusBarTextColor

        Behavior on x {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
    }

    HoverHandler { cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: root.toggled() }
}
