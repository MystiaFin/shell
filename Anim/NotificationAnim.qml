import QtQuick

Item {
    id: root

    property var targetTransform: null
    property var targetModel: null
    property int targetIndex: -1

    // Configuration
    property int autoHideDuration: 6000
    property int slideInDuration: 400
    property int slideOutDuration: 350

    // Position Configuration
    property int startX: 400
    property int settledX: 36
    property int exitX: 450

    // Initialize position and start entry animation
    Component.onCompleted: {
        if (targetTransform) {
            targetTransform.x = startX;
            slideInAnim.start();
        }
    }

    // Entry Animation
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
                if (root.targetModel && root.targetModel.close) {
                    root.targetModel.close();
                }
                if (root.parent) {
                    root.parent.visible = false;
                    root.parent.height = 0;
                    root.parent.width = 0;
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
