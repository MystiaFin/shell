import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: overlayRoot
    
    property var modelData
    property var screen: modelData
    required property color bgColor
    property int cornerRadius: 16
    property int topMargin: 40
    
    WlrLayershell.namespace: "overlay-mask"
    WlrLayershell.layer: WlrLayer.Top  // Or WlrLayer.Overlay for even higher
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrLayershell.None
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    color: "transparent"

    // Mask source (invisible)
    Item {
        id: maskItem
        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: overlayRoot.topMargin
            color: "black"
            radius: overlayRoot.cornerRadius
        }
    }

    // Blue overlay with inverted mask
    Rectangle {
        id: overlay
        anchors.fill: parent
        color: overlayRoot.bgColor

        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: maskItem
            maskInverted: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }
    }
}
