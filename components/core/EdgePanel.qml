import QtQuick
import "../common"
import "../theme"

Item {
    id: root

    enum Edge {
        Top,
        Right,
        Bottom,
        Left
    }

    enum EdgeAlignment {
        Start,
        Center,
        End
    }

    required property var host

    default property alias content: contentLayer.data

    property bool shown: false
    property bool wantsKeyboardFocus: false
    property Item focusTarget: null

    property int edge: EdgePanel.Bottom
    property int edgeAlignment: EdgePanel.Center
    property real alongEdgeOffset: 0
    property real edgeOffset: ShellMetrics.panelScreenEdgeOverlap

    property real targetWidth: 320
    property real targetHeight: 180
    property real radius: ShellMetrics.panelRadius
    property real hiddenMargin: 32
    property real closedWidthScale: 0.96
    property real motionStiffness: 250
    property real motionDamping: 31.62
    property real closeMotionDamping: motionDamping

    readonly property bool animationsReady: host && host.animationsReady
    readonly property real motionProgress: revealMotion.value
    readonly property real restingX: {
        if (!host)
            return 0;
        if (edge === EdgePanel.Left)
            return -edgeOffset;
        if (edge === EdgePanel.Right)
            return host.width - width + edgeOffset;

        if (edgeAlignment === EdgePanel.Start)
            return alongEdgeOffset;
        if (edgeAlignment === EdgePanel.End)
            return host.width - width - alongEdgeOffset;
        return (host.width - width) / 2 + alongEdgeOffset;
    }
    readonly property real restingY: {
        if (!host)
            return 0;
        if (edge === EdgePanel.Top)
            return -edgeOffset;
        if (edge === EdgePanel.Bottom)
            return host.height - height + edgeOffset;

        if (edgeAlignment === EdgePanel.Start)
            return alongEdgeOffset;
        if (edgeAlignment === EdgePanel.End)
            return host.height - height - alongEdgeOffset;
        return (host.height - height) / 2 + alongEdgeOffset;
    }
    readonly property real hiddenSlideOffset: {
        if (edge === EdgePanel.Top || edge === EdgePanel.Left)
            return -(edge === EdgePanel.Top ? targetHeight : targetWidth)
                - hiddenMargin;
        if (edge === EdgePanel.Right)
            return targetWidth + hiddenMargin;
        return targetHeight + hiddenMargin;
    }
    readonly property real slideOffset: hiddenSlideOffset * (1 - motionProgress)

    x: restingX + ((edge === EdgePanel.Left || edge === EdgePanel.Right)
        ? slideOffset
        : 0)
    y: restingY + ((edge === EdgePanel.Top
        || edge === EdgePanel.Bottom)
        ? slideOffset
        : 0)
    width: targetWidth * (closedWidthScale
        + (1 - closedWidthScale) * motionProgress)
    height: heightMotion.value
    clip: true

    SpringMotion {
        id: revealMotion

        enabled: root.animationsReady
        target: root.shown ? 1 : 0
        stiffness: root.motionStiffness
        damping: root.shown ? root.motionDamping : root.closeMotionDamping
        positionEpsilon: 0.0005
        velocityEpsilon: 0.001
    }

    SpringMotion {
        id: heightMotion

        enabled: root.animationsReady
        target: root.targetHeight
        positionEpsilon: 0.1
        velocityEpsilon: 0.1
    }

    Item {
        id: contentLayer
        anchors.fill: parent
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: {
            if (root.shown && root.focusTarget)
                root.focusTarget.forceActiveFocus();
        }
    }

    onShownChanged: {
        if (shown && wantsKeyboardFocus)
            focusTimer.restart();
    }
}
