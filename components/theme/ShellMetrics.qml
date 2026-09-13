pragma Singleton

import Quickshell

Singleton {
    readonly property real liquidEdgeOffset: 2
    readonly property real panelScreenEdgeOverlap: 40
    readonly property real panelContentInsetFromEdge: 56
    readonly property real liquidConnectionRadius: 24
    readonly property real radiusSmall: 8
    readonly property real radiusMedium: 12
    readonly property real radiusLarge: 16
    readonly property real radiusExtraLarge: 20
    readonly property real panelRadius: 30
    readonly property real desktopFrameRadius: 28
    readonly property real shadowSize: 8
    readonly property real shadowBlur: 0.6
    readonly property real shadowVerticalOffset: 4

    // Material's standard curve for spatial changes, paired with shorter
    // effects timing. Curves include the final [1, 1] Bezier endpoint.
    readonly property var spatialEasingCurve: [0.2, 0, 0, 1, 1, 1]
    readonly property var effectsEasingCurve: [0.34, 0.8, 0.34, 1, 1, 1]
    readonly property int fastEffectsDurationMs: 100
    readonly property int defaultEffectsDurationMs: 140
    readonly property int fastSpatialDurationMs: 240
    readonly property int defaultSpatialDurationMs: 340
    readonly property int slowSpatialDurationMs: 460
    readonly property int floatingWidgetTransitionDurationMs: 650
    readonly property int wallpaperRevealDurationMs: 1200
    readonly property real continuousMotionVelocity: 850
    readonly property real fastPanelSpringStiffness: 500
    readonly property real fastPanelSpringDamping: 44.72
    readonly property real fastPanelCloseSpringDamping: 50
    readonly property int initializationDelayMs: 100

    readonly property real statusBarHeight: 40
    readonly property int startupBlockFadeDurationMs: 280
    readonly property int startupMaskRevealDurationMs: 700
    readonly property int startupStatusBarDurationMs: 420
    readonly property int popupTimeoutMs: 6000
    readonly property int exitGracePeriodMs: 180
    readonly property int initialHoverGracePeriodMs: 650
}
