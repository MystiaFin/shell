import QtQuick

SequentialAnimation {
    id: scrollAnim
    
    property var textTarget: null
    property string fullText: ""
    
    running: false
    loops: Animation.Infinite
    
    NumberAnimation {
        target: scrollAnim.textTarget
        property: "x"
        from: 0
        to: scrollAnim.textTarget ? -(scrollAnim.textTarget.implicitWidth / 2) : 0
        duration: scrollAnim.fullText.length * 200
        easing.type: Easing.Linear
    }
    
    PauseAnimation {
        duration: 2000
    }
    
    PropertyAction {
        target: scrollAnim.textTarget
        property: "x"
        value: 0
    }
    
    function restart() {
        stop();
        if (textTarget) {
            textTarget.x = 0;
        }
        start();
    }
}
