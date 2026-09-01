import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    default property alias widgets: widgetLayer.data

    readonly property bool isLiquidWidgetHost: true
    property bool animationsReady: false
    property color liquidColor: Theme.liquidColor
    property real edgeFieldOffset: LiquidMetrics.edgeFieldOffset
    property real connectionRadius: LiquidMetrics.connectionRadius

    readonly property var liquidWidgets: widgetLayer.children.filter(widget =>
        widget.isLiquidWidget === true && widget.contributesToShape)
    readonly property bool keyboardRequested: liquidWidgets.some(widget =>
        widget.shown && widget.wantsKeyboardFocus)

    function widgetAt(index: int): Item {
        return index >= 0 && index < liquidWidgets.length
            ? liquidWidgets[index]
            : null;
    }

    function widgetRect(index: int): rect {
        const widget = widgetAt(index);
        return widget
            ? Qt.rect(widget.x, widget.y, widget.width, widget.height)
            : Qt.rect(0, 0, 0, 0);
    }

    function widgetRadius(index: int): real {
        const widget = widgetAt(index);
        return widget ? widget.radius : 0;
    }

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
        Region { item: root.widgetAt(0) }
        Region { item: root.widgetAt(1) }
        Region { item: root.widgetAt(2) }
        Region { item: root.widgetAt(3) }
        Region { item: root.widgetAt(4) }
        Region { item: root.widgetAt(5) }
        Region { item: root.widgetAt(6) }
        Region { item: root.widgetAt(7) }
    }

    SdfLiquidSurface {
        anchors.fill: parent
        color: root.liquidColor
        edgeOffset: root.edgeFieldOffset
        connectionRadius: root.connectionRadius
        shapeCount: Math.min(root.liquidWidgets.length, 8)

        shape0: root.widgetRect(0)
        shape1: root.widgetRect(1)
        shape2: root.widgetRect(2)
        shape3: root.widgetRect(3)
        shape4: root.widgetRect(4)
        shape5: root.widgetRect(5)
        shape6: root.widgetRect(6)
        shape7: root.widgetRect(7)

        radius0: root.widgetRadius(0)
        radius1: root.widgetRadius(1)
        radius2: root.widgetRadius(2)
        radius3: root.widgetRadius(3)
        radius4: root.widgetRadius(4)
        radius5: root.widgetRadius(5)
        radius6: root.widgetRadius(6)
        radius7: root.widgetRadius(7)
    }

    Item {
        id: widgetLayer
        anchors.fill: parent
    }

    Timer {
        interval: LiquidMetrics.initializationDelay
        running: root.backingWindowVisible && !root.animationsReady
        onTriggered: root.animationsReady = true
    }
}
