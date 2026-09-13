import QtQuick
import "../theme"

NumberAnimation {
    enum Type {
        FastEffects,
        DefaultEffects,
        FastSpatial,
        DefaultSpatial,
        SlowSpatial
    }

    property int type: MotionAnimation.DefaultSpatial

    duration: {
        if (type === MotionAnimation.FastEffects)
            return ShellMetrics.fastEffectsDurationMs;
        if (type === MotionAnimation.DefaultEffects)
            return ShellMetrics.defaultEffectsDurationMs;
        if (type === MotionAnimation.FastSpatial)
            return ShellMetrics.fastSpatialDurationMs;
        if (type === MotionAnimation.SlowSpatial)
            return ShellMetrics.slowSpatialDurationMs;
        return ShellMetrics.defaultSpatialDurationMs;
    }
    easing.type: Easing.BezierSpline
    easing.bezierCurve: type === MotionAnimation.FastEffects
        || type === MotionAnimation.DefaultEffects
        ? ShellMetrics.effectsEasingCurve
        : ShellMetrics.spatialEasingCurve
}
