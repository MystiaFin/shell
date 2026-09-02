import QtQuick
import "../theme"

Item {
    id: root

    enum Edge {
        Top,
        Right,
        Bottom,
        Left,
        Floating
    }

    enum EdgeAlignment {
        Start,
        Center,
        End
    }

    required property var host

    default property alias content: contentLayer.data

    readonly property bool isEdgePanel: true
    property bool shown: false
    property bool contributesToShape: true
    property bool wantsKeyboardFocus: false
    property Item focusTarget: null

    property int edge: EdgePanel.Bottom
    property int edgeAlignment: EdgePanel.Center
    property real alongEdgeOffset: 0
    property real edgeOffset: ShellMetrics.panelScreenEdgeOverlap
    property real floatingX: 0
    property real floatingY: 0

    property real targetWidth: 320
    property real targetHeight: 180
    property real radius: ShellMetrics.panelRadius
    property real hiddenMargin: 32
    property real closedWidthScale: 0.96

    property int slideDurationMs: ShellMetrics.panelSlideDurationMs
    property int slideEasing: Easing.OutBack
    property real slideOvershoot: ShellMetrics.panelSlideOvershoot
    property int widthAnimationDurationMs: ShellMetrics.panelResizeDurationMs
    property int widthEasing: Easing.OutBack
    property real widthOvershoot: ShellMetrics.panelResizeOvershoot
    property int heightAnimationDurationMs: 340
    property int resizeEasing: Easing.OutCubic

    readonly property bool animationsReady: host && host.animationsReady
    readonly property real restingX: {
        if (!host)
            return 0;
        if (edge === EdgePanel.Left)
            return -edgeOffset;
        if (edge === EdgePanel.Right)
            return host.width - width + edgeOffset;
        if (edge === EdgePanel.Floating)
            return floatingX;

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
        if (edge === EdgePanel.Floating)
            return floatingY;

        if (edgeAlignment === EdgePanel.Start)
            return alongEdgeOffset;
        if (edgeAlignment === EdgePanel.End)
            return host.height - height - alongEdgeOffset;
        return (host.height - height) / 2 + alongEdgeOffset;
    }
    property real slideOffset: {
        if (shown)
            return 0;
        if (edge === EdgePanel.Top || edge === EdgePanel.Left)
            return -(edge === EdgePanel.Top ? height : width) - hiddenMargin;
        if (edge === EdgePanel.Right)
            return width + hiddenMargin;
        return height + hiddenMargin;
    }

    x: restingX + ((edge === EdgePanel.Left || edge === EdgePanel.Right)
        ? slideOffset
        : 0)
    y: restingY + ((edge === EdgePanel.Top
        || edge === EdgePanel.Bottom
        || edge === EdgePanel.Floating)
        ? slideOffset
        : 0)
    width: shown ? targetWidth : targetWidth * closedWidthScale
    height: targetHeight
    clip: true

    Behavior on width {
        enabled: root.animationsReady

        NumberAnimation {
            duration: root.widthAnimationDurationMs
            easing.type: root.widthEasing
            easing.overshoot: root.widthOvershoot
        }
    }

    Behavior on height {
        enabled: root.animationsReady

        NumberAnimation {
            duration: root.heightAnimationDurationMs
            easing.type: root.resizeEasing
        }
    }

    Behavior on slideOffset {
        enabled: root.animationsReady

        NumberAnimation {
            duration: root.slideDurationMs
            easing.type: root.slideEasing
            easing.overshoot: root.slideOvershoot
        }
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
