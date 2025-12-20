pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects 

PanelWindow {
    id: root

    // --- Window Setup ---
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // --- 1. The Raw Shapes (Hidden) ---
    // This is the geometry: Bottom Bar + Moving Widget
    Item {
        id: shapeSource
        anchors.fill: parent
        visible: false 

        // The Bottom Bar
        Rectangle {
            width: 100
            height: 50
            radius: 10
            color: "white" // Must be white for the mask to read it
            
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 100
        }

        // The Moving Widget
        Rectangle {
            width: 100
            height: 50
            radius: 10
            color: "white" 
            
            anchors.horizontalCenter: parent.horizontalCenter

            SequentialAnimation on y {
                loops: Animation.Infinite
                running: true
                
                // Move Down (Touch)
                NumberAnimation {
                    // Target: Overlap bottom rect by 20px
                    to: root.height - 100 - 50 - 20
                    from: root.height - 300
                    duration: 1000
                    easing.type: Easing.InOutSine
                }
                
                // Move Up
                NumberAnimation {
                    to: root.height - 300
                    from: root.height - 100 - 50 - 20
                    duration: 1000
                    easing.type: Easing.InOutSine
                }
            }
        }
    }

    // --- 2. The Blur (Hidden) ---
    // Smears the white shapes together
    FastBlur {
        id: blurredShapes
        anchors.fill: parent
        source: shapeSource
        radius: 32 // High radius = stronger liquid bridge
        visible: false 
    }

    // --- 3. The Color Source (Hidden) ---
    // This is the actual color you want the UI to be
    Rectangle {
        id: uiColor
        anchors.fill: parent
        color: "#cdd6f4" 
        visible: false
    }

    // --- 4. The Result (Visible) ---
    // Uses the Blur to cut the Color
    ThresholdMask {
        anchors.fill: parent
        
        source: uiColor        // The color to draw
        maskSource: blurredShapes // The shape to cut out
        
        threshold: 0.45  // < 0.45 is transparent, > 0.45 is solid
        spread: 0.05     // Anti-aliasing for smooth edges
    }
}
