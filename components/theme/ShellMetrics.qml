pragma Singleton

import Quickshell
import "../../services"

Singleton {
    readonly property real uiScale: SettingsService.uiScale
    readonly property real cornerScale: SettingsService.cornerRadiusScale

    function scaled(value: real): real {
        return value * uiScale;
    }

    function rounded(value: real): real {
        return value * uiScale * cornerScale;
    }

    readonly property real liquidEdgeOffset: scaled(2)
    readonly property real panelScreenEdgeOverlap: scaled(40)
    readonly property real panelContentInsetFromEdge: scaled(56)
    readonly property real liquidConnectionRadius: rounded(24)
    readonly property real radiusSmall: rounded(8)
    readonly property real radiusMedium: rounded(12)
    readonly property real radiusLarge: rounded(16)
    readonly property real radiusExtraLarge: rounded(20)
    readonly property real panelRadius: rounded(30)
    readonly property real desktopFrameRadius: rounded(28)
    readonly property real shadowSize: scaled(8)
    readonly property real shadowBlur: 0.6
    readonly property real shadowVerticalOffset: scaled(4)

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

    readonly property real statusBarHeight: SettingsService.statusBarHeight * uiScale
    readonly property int startupBlockFadeDurationMs: 280
    readonly property int startupMaskRevealDurationMs: 700
    readonly property int startupStatusBarDurationMs: 420
    readonly property int popupTimeoutMs: 6000
    readonly property int exitGracePeriodMs: 180
    readonly property int initialHoverGracePeriodMs: 650
}
