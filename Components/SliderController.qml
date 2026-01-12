import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    height: 24
    implicitWidth: 300
    property color sliderColor: "#89b4fa"
    property color bgColor: "#45475a"
    property string startIcon: ""
    property string endIcon: ""
    property real value: 0
    property var onMoved: null
    
    RowLayout {
        anchors.fill: parent
        spacing: 12
        
        Text {
            visible: root.startIcon !== ""
            text: root.startIcon
            font.pixelSize: 18
            color: "#cdd6f4"
            Layout.alignment: Qt.AlignVCenter
        }
        
        Slider {
            id: slider
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            from: 0
            to: 1.0
            stepSize: 0.01
            value: root.value
            
            onMoved: {
                if (root.onMoved) {
                    root.onMoved(value)
                }
            }
            
            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitHeight: 6
                width: slider.availableWidth
                height: implicitHeight
                radius: 3
                color: root.bgColor
                
                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    color: root.sliderColor
                    radius: 3
                }
            }
            
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                
                implicitWidth: 10
                implicitHeight: 24
                radius: 5
                color: "#f5e0dc"
                border.color: root.sliderColor
                border.width: 1
                
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
                
                Text {
                    visible: slider.pressed
                    x: (parent.width - width) / 2
                    y: parent.height + 8
                    text: Math.round(slider.value * 100) + "%"
                    font.pixelSize: 11
                    color: "#cdd6f4"
                }
            }
        }
        
        Text {
            visible: root.endIcon !== ""
            text: root.endIcon
            font.pixelSize: 18
            color: "#cdd6f4"
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
