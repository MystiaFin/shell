import QtQuick
import "../theme"

Item {
    id: root

    required property bool active
    required property bool panelHovered
    required property bool externalHovered

    property bool hasBeenHoveredSinceOpened: false
    property int exitGracePeriodMs: ShellMetrics.exitGracePeriodMs
    property int initialHoverGracePeriodMs: ShellMetrics.initialHoverGracePeriodMs

    signal dismissRequested()

    visible: false

    function scheduleDismissIfOutside(): void {
        if (active && !panelHovered && !externalHovered)
            exitGraceTimer.restart();
    }

    onPanelHoveredChanged: {
        if (panelHovered) {
            hasBeenHoveredSinceOpened = true;
            exitGraceTimer.stop();
        } else if (hasBeenHoveredSinceOpened) {
            scheduleDismissIfOutside();
        }
    }

    onExternalHoveredChanged: {
        if (externalHovered)
            exitGraceTimer.stop();
        else
            scheduleDismissIfOutside();
    }

    onActiveChanged: {
        if (active) {
            hasBeenHoveredSinceOpened = false;
            initialHoverTimer.restart();
        } else {
            initialHoverTimer.stop();
            exitGraceTimer.stop();
        }
    }

    Timer {
        id: exitGraceTimer
        interval: root.exitGracePeriodMs
        onTriggered: {
            if (root.active && !root.panelHovered && !root.externalHovered)
                root.dismissRequested();
        }
    }

    Timer {
        id: initialHoverTimer
        interval: root.initialHoverGracePeriodMs
        onTriggered: {
            if (root.active && !root.panelHovered && !root.externalHovered)
                root.dismissRequested();
        }
    }
}
