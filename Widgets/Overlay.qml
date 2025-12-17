import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects

PanelWindow {
    id: root

    color: "transparent"
    visible: true
    WlrLayershell.layer: WlrLayer.Top

    mask: Region {
        item: container
        intersection: Intersection.Xor
    }

    anchors {
        top: true
        left: true
        bottom: true
        right: true
    }

    Item {
        id: container
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent

            color: "#1e1e2e"

            layer.enabled: true
            layer.effect: MultiEffect {
                maskSource: mask
                maskEnabled: true
                maskInverted: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1
            }
        }

        Item {
            id: mask

            anchors.fill: parent
            layer.enabled: true
            visible: false

            Rectangle {
                anchors.fill: parent

                radius: 18
            }
        }
    }
}
