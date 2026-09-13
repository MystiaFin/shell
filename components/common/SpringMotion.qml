import QtQuick

QtObject {
    id: root

    property bool enabled: true
    property real stiffness: 250
    property real damping: 31.62
    property real mass: 1
    property real positionEpsilon: 0.001
    property real velocityEpsilon: 0.001
    property real maximumFrameTime: 1 / 30
    property real integrationStep: 1 / 240
    property real value: 0
    property real target: 0
    property real velocity: 0

    readonly property bool running: privateState.running

    function settled(): bool {
        return Math.abs(target - value) <= positionEpsilon
            && Math.abs(velocity) <= velocityEpsilon;
    }

    function snapToTarget(): void {
        value = target;
        velocity = 0;
        privateState.running = false;
    }

    function advance(rawFrameTime: real): void {
        if (!enabled || !privateState.running)
            return;

        const frameTime = Math.min(Math.max(rawFrameTime, 0), maximumFrameTime);
        if (frameTime <= 0)
            return;

        const steps = Math.max(1, Math.ceil(frameTime / integrationStep));
        const step = frameTime / steps;
        const inverseMass = 1 / Math.max(0.001, mass);

        for (let index = 0; index < steps; index++) {
            velocity += (stiffness * (target - value) - damping * velocity)
                * inverseMass * step;
            value += velocity * step;
        }

        if (settled())
            snapToTarget();
    }

    onTargetChanged: {
        if (!enabled) {
            snapToTarget();
        } else if (!settled()) {
            privateState.running = true;
        }
    }
    onEnabledChanged: {
        if (!enabled)
            snapToTarget();
        else if (!settled())
            privateState.running = true;
    }
    Component.onCompleted: snapToTarget()

    property QtObject privateState: QtObject {
        property bool running: false
    }

    property FrameAnimation driver: FrameAnimation {
        running: root.enabled && root.privateState.running
        onTriggered: root.advance(frameTime)
    }
}
