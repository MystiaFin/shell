import QtQuick
import "../Anim"

Item {
    id: root
    
    property color ringColor: "#89b4fa"
    property color bgColor: "#45475a"
    property real ringWidth: 4
    property real value: 0.5
    property var onScroll: null
    property bool showNumber: true
    
    property real displayValue: value
    
    width: 16
    height: 16
    
    Behavior on displayValue {
        ControlPanelAnim {}
    }
    
    onValueChanged: {
        displayValue = value
    }
    
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: root.bgColor
        border.width: root.ringWidth
    }
    
    Canvas {
        id: canvas
        anchors.fill: parent
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            
            var centerX = width / 2;
            var centerY = height / 2;
            var radius = (width / 2) - (root.ringWidth / 2);
            
            var startAngle = -Math.PI / 2;
            var endAngle = startAngle + (2 * Math.PI * root.displayValue);
            
            ctx.lineCap = "round";
            ctx.lineWidth = root.ringWidth;
            ctx.strokeStyle = root.ringColor;
            
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, startAngle, endAngle, false);
            ctx.stroke();
        }
    }
    
    Text {
        visible: root.showNumber
        anchors.centerIn: parent
        text: Math.round(root.displayValue * 100)
        color: "#cdd6f4"
        font.pixelSize: root.width * 0.3
        font.family: "Poppins"
    }
    
    MouseArea {
        anchors.fill: parent
        onWheel: (wheel) => {
            if (root.onScroll) {
                var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                root.onScroll(delta)
            }
        }
    }
    
    onDisplayValueChanged: canvas.requestPaint()
}
