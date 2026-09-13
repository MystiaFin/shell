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
        if (SettingsService.reduceMotion || configuredStyle === "off")
            return 0;
        if (configuredDuration !== undefined)
            return Math.round(configuredDuration / Math.max(0.1, SettingsService.globalAnimationSpeed));
        if (type === MotionAnimation.FastEffects)
            return Math.round(ShellMetrics.fastEffectsDurationMs / Math.max(0.1, SettingsService.globalAnimationSpeed));
        if (type === MotionAnimation.DefaultEffects)
            return Math.round(ShellMetrics.defaultEffectsDurationMs / Math.max(0.1, SettingsService.globalAnimationSpeed));
        if (type === MotionAnimation.FastSpatial)
            return Math.round(ShellMetrics.fastSpatialDurationMs / Math.max(0.1, SettingsService.globalAnimationSpeed));
        if (type === MotionAnimation.SlowSpatial)
            return Math.round(ShellMetrics.slowSpatialDurationMs / Math.max(0.1, SettingsService.globalAnimationSpeed));
        return Math.round(ShellMetrics.defaultSpatialDurationMs / Math.max(0.1, SettingsService.globalAnimationSpeed));
    }
    easing.type: Easing.BezierSpline
    easing.bezierCurve: configuredStyle === "fade"
        || type === MotionAnimation.FastEffects
        || type === MotionAnimation.DefaultEffects
        ? ShellMetrics.effectsEasingCurve
        : ShellMetrics.spatialEasingCurve
}
