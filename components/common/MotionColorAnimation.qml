import QtQuick
import "../theme"
import "../../services"

ColorAnimation {
    property int type: MotionAnimation.DefaultEffects
    property string group: "content"

    readonly property int configuredDuration: SettingsService[group + "Duration"]
    readonly property string configuredStyle: SettingsService[group + "Animation"] || "spatial"

    duration: SettingsService.reduceMotion || configuredStyle === "off" ? 0
        : Math.round(configuredDuration / Math.max(0.1, SettingsService.globalAnimationSpeed))
    easing.type: Easing.BezierSpline
    easing.bezierCurve: ShellMetrics.effectsEasingCurve
}
