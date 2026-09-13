import QtQuick
import "../theme"
import "../../services"

NumberAnimation {
    enum Type {
        FastEffects,
        DefaultEffects,
        FastSpatial,
        DefaultSpatial,
        SlowSpatial
    }

    property int type: MotionAnimation.DefaultSpatial
    property string group: "content"
    readonly property string configuredStyle: SettingsService[group + "Animation"] || "spatial"
    readonly property int configuredDuration: SettingsService[group + "Duration"]

    duration: {
        if (configuredStyle === "off")
            return 0;
        if (configuredDuration !== undefined)
            return configuredDuration;
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
    easing.bezierCurve: configuredStyle === "fade"
        || type === MotionAnimation.FastEffects
        || type === MotionAnimation.DefaultEffects
        ? ShellMetrics.effectsEasingCurve
        : ShellMetrics.spatialEasingCurve
}
