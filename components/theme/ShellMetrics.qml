pragma Singleton

import Quickshell

Singleton {
    readonly property real liquidEdgeOffset: 2
    readonly property real panelScreenEdgeOverlap: 40
    readonly property real panelContentInsetFromEdge: 56
    readonly property real liquidConnectionRadius: 24
    readonly property real panelRadius: 30

    readonly property int panelSlideDurationMs: 480
    readonly property real panelSlideOvershoot: 0.65
    readonly property int panelResizeDurationMs: 440
    readonly property real panelResizeOvershoot: 0.45
    readonly property int initializationDelayMs: 100

    readonly property real statusBarHeight: 40
    readonly property int fastAnimationMs: 180
    readonly property int pageTransitionDurationMs: 260
    readonly property int popupTimeoutMs: 6000
    readonly property int exitGracePeriodMs: 180
    readonly property int initialHoverGracePeriodMs: 650
}
