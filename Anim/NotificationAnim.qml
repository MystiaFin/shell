import QtQuick
Item {
    id: root
    property var targetTransform: null
    property var targetModel: null
    property int targetIndex: -1
    property int autoHideDuration: 6000
    property int slideInDuration: 400
    property int slideOutDuration: 350
    property int startX: 400
    property int settledX: 36
    property int exitX: 450
    
    signal removeRequested(int notifId)
    
    Component.onCompleted: {
        if (targetTransform) {
            targetTransform.x = startX;
            slideInAnim.start();
        }
    }
    
    NumberAnimation {
        id: slideInAnim
        target: root.targetTransform
        property: "x"
        from: root.startX
        to: root.settledX
        duration: root.slideInDuration
        easing.type: Easing.OutCubic
    }
    
    SequentialAnimation {
        id: exitAnim
        NumberAnimation {
            target: root.targetTransform
            property: "x"
            to: root.exitX
            duration: root.slideOutDuration
            easing.type: Easing.InCubic
        }
        ScriptAction {
            script: {
                if (root.targetModel && root.targetModel.id !== undefined) {
                    root.removeRequested(root.targetModel.id);
                }
            }
        }
    }
    
    Timer {
        interval: root.autoHideDuration
        running: true
        onTriggered: exitAnim.start()
    }
    
    function close() {
        exitAnim.start();
    }
}
