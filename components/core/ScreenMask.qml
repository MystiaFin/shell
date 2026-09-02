import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import "../theme"

PanelWindow {
    id: root

    required property var modelData
    readonly property var targetScreen: modelData

    property real cornerRadius: 18
    property real topInset: 40

    screen: targetScreen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "screen-mask"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region {
        item: container
        intersection: Intersection.Xor
    }

    Item {
        id: container
        anchors.fill: parent

        Rectangle {
            anchors {
                top: parent.top
                topMargin: root.topInset
                right: parent.right
                bottom: parent.bottom
                left: parent.left
            }
            color: Theme.shellBackgroundColor

            layer.enabled: true
            layer.effect: MultiEffect {
                maskSource: roundedMask
                maskEnabled: true
                maskInverted: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1
            }
        }

        Item {
            id: roundedMask
            anchors {
                top: parent.top
                topMargin: root.topInset
                right: parent.right
                bottom: parent.bottom
                left: parent.left
            }
            layer.enabled: true
            visible: false

            Rectangle {
                anchors.fill: parent
                radius: root.cornerRadius
            }
        }
    }
}
