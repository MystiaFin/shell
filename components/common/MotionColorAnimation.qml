import QtQuick
import "../theme"

ColorAnimation {
    property int type: MotionAnimation.DefaultEffects

    duration: type === MotionAnimation.FastEffects
        ? ShellMetrics.fastEffectsDurationMs
        : ShellMetrics.defaultEffectsDurationMs
    easing.type: Easing.BezierSpline
    easing.bezierCurve: ShellMetrics.effectsEasingCurve
}
