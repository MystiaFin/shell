import QtQuick

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

    readonly property bool isEdgeWidget: true
    property bool shown: false
    property bool contributesToShape: true
    property bool wantsKeyboardFocus: false
    property Item focusTarget: null

    property int edge: EdgeWidget.Bottom
    property int edgeAlignment: EdgeWidget.Center
    property real alongEdgeOffset: 0
    property real edgeOffset: WidgetMetrics.edgeOverlap
    property real floatingX: 0
    property real floatingY: 0

    property real targetWidth: 320
    property real targetHeight: 180
    property real radius: WidgetMetrics.widgetRadius
    property real hiddenMargin: 32
    property real closedWidthScale: 0.96

    property int slideDuration: WidgetMetrics.slideDuration
    property int slideEasing: Easing.OutBack
    property real slideOvershoot: WidgetMetrics.slideOvershoot
    property int widthDuration: WidgetMetrics.widthDuration
    property int widthEasing: Easing.OutBack
    property real widthOvershoot: WidgetMetrics.widthOvershoot
    property int resizeDuration: 340
    property int resizeEasing: Easing.OutCubic

    readonly property bool animationsReady: host && host.animationsReady
    readonly property real restingX: {
        if (!host)
            return 0;
        if (edge === EdgeWidget.Left)
            return -edgeOffset;
        if (edge === EdgeWidget.Right)
            return host.width - width + edgeOffset;
        if (edge === EdgeWidget.Floating)
            return floatingX;

        if (edgeAlignment === EdgeWidget.Start)
            return alongEdgeOffset;
        if (edgeAlignment === EdgeWidget.End)
            return host.width - width - alongEdgeOffset;
        return (host.width - width) / 2 + alongEdgeOffset;
    }
    readonly property real restingY: {
        if (!host)
            return 0;
        if (edge === EdgeWidget.Top)
            return -edgeOffset;
        if (edge === EdgeWidget.Bottom)
            return host.height - height + edgeOffset;
        if (edge === EdgeWidget.Floating)
            return floatingY;

        if (edgeAlignment === EdgeWidget.Start)
            return alongEdgeOffset;
        if (edgeAlignment === EdgeWidget.End)
            return host.height - height - alongEdgeOffset;
        return (host.height - height) / 2 + alongEdgeOffset;
    }
    property real slideOffset: {
        if (shown)
            return 0;
        if (edge === EdgeWidget.Top || edge === EdgeWidget.Left)
            return -(edge === EdgeWidget.Top ? height : width) - hiddenMargin;
        if (edge === EdgeWidget.Right)
            return width + hiddenMargin;
        return height + hiddenMargin;
    }

    x: restingX + ((edge === EdgeWidget.Left || edge === EdgeWidget.Right)
        ? slideOffset
        : 0)
    y: restingY + ((edge === EdgeWidget.Top
        || edge === EdgeWidget.Bottom
        || edge === EdgeWidget.Floating)
        ? slideOffset
        : 0)
    width: shown ? targetWidth : targetWidth * closedWidthScale
    height: targetHeight
    clip: true

    Behavior on width {
        enabled: root.animationsReady

        NumberAnimation {
            duration: root.widthDuration
            easing.type: root.widthEasing
            easing.overshoot: root.widthOvershoot
        }
    }

    Behavior on height {
        enabled: root.animationsReady

        NumberAnimation {
            duration: root.resizeDuration
            easing.type: root.resizeEasing
        }
    }

    Behavior on slideOffset {
        enabled: root.animationsReady

        NumberAnimation {
            duration: root.slideDuration
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
