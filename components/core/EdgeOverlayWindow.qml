import Quickshell
import Quickshell.Wayland
import QtQuick
import "../effects"
import "../theme"

PanelWindow {
    id: root

    default property alias panels: panelLayer.data

    property bool animationsReady: false
    property color liquidColor: Theme.liquidColor
    property real edgeFieldOffset: ShellMetrics.liquidEdgeOffset
    property real connectionRadius: ShellMetrics.liquidConnectionRadius
    readonly property int maximumShapeCount: 8

    readonly property var edgePanels: panelLayer.children.filter(panel =>
        panel.isEdgePanel === true)
    readonly property var shapeContributors: edgePanels.filter(panel =>
        panel.contributesToShape)
    readonly property bool keyboardRequested: edgePanels.some(panel =>
        panel.shown && panel.wantsKeyboardFocus)

    function shapeContributorAt(index: int): Item {
        return index >= 0 && index < shapeContributors.length
            ? shapeContributors[index]
            : null;
    }

    function shapeRect(index: int): rect {
        const panel = shapeContributorAt(index);
        return panel
            ? Qt.rect(panel.x, panel.y, panel.width, panel.height)
            : Qt.rect(0, 0, 0, 0);
    }

    function shapeRadius(index: int): real {
        const panel = shapeContributorAt(index);
        return panel ? panel.radius : 0;
    }

    function warnIfShapeLimitExceeded(): void {
        if (shapeContributors.length > maximumShapeCount) {
            console.warn("EdgeOverlayWindow supports at most", maximumShapeCount,
                "liquid shape contributors; ignoring",
                shapeContributors.length - maximumShapeCount);
        }
    }

    onShapeContributorsChanged: warnIfShapeLimitExceeded()

    color: Theme.windowColor
    exclusiveZone: 0
    WlrLayershell.keyboardFocus: keyboardRequested
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    mask: Region {
        Region { item: root.shapeContributorAt(0) }
        Region { item: root.shapeContributorAt(1) }
        Region { item: root.shapeContributorAt(2) }
        Region { item: root.shapeContributorAt(3) }
        Region { item: root.shapeContributorAt(4) }
        Region { item: root.shapeContributorAt(5) }
        Region { item: root.shapeContributorAt(6) }
        Region { item: root.shapeContributorAt(7) }
    }

    SdfLiquidSurface {
        anchors.fill: parent
        color: root.liquidColor
        edgeOffset: root.edgeFieldOffset
        connectionRadius: root.connectionRadius
        shapeCount: Math.min(root.shapeContributors.length, root.maximumShapeCount)

        shape0: root.shapeRect(0)
        shape1: root.shapeRect(1)
        shape2: root.shapeRect(2)
        shape3: root.shapeRect(3)
        shape4: root.shapeRect(4)
        shape5: root.shapeRect(5)
        shape6: root.shapeRect(6)
        shape7: root.shapeRect(7)

        radius0: root.shapeRadius(0)
        radius1: root.shapeRadius(1)
        radius2: root.shapeRadius(2)
        radius3: root.shapeRadius(3)
        radius4: root.shapeRadius(4)
        radius5: root.shapeRadius(5)
        radius6: root.shapeRadius(6)
        radius7: root.shapeRadius(7)
    }

    Item {
        id: panelLayer
        anchors.fill: parent
    }

    Timer {
        interval: ShellMetrics.initializationDelayMs
        running: root.backingWindowVisible && !root.animationsReady
        onTriggered: root.animationsReady = true
    }
}
