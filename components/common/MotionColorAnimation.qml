import QtQuick
import "../theme"
import "../../services"

ColorAnimation {
    property int type: MotionAnimation.DefaultEffects
    property string group: "content"

    duration: SettingsService[group + "Animation"] === "off" ? 0
        : SettingsService[group + "Duration"]
    easing.type: Easing.BezierSpline
    easing.bezierCurve: ShellMetrics.effectsEasingCurve
}
