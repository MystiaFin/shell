import QtQuick
import "../theme"

Item {
    id: root

    property color color: Theme.liquidColor
    property real edgeOffset: 2
    property real connectionRadius: 36
    // The shader uniform layout has exactly eight shape/radius slots.
    readonly property int maximumShapeCount: 8
    property int shapeCount: 0

    onShapeCountChanged: {
        if (shapeCount > maximumShapeCount)
            console.warn("SdfLiquidSurface shapeCount exceeds its eight-shape limit");
    }

    property rect shape0: Qt.rect(0, 0, 0, 0)
    property rect shape1: Qt.rect(0, 0, 0, 0)
    property rect shape2: Qt.rect(0, 0, 0, 0)
    property rect shape3: Qt.rect(0, 0, 0, 0)
    property rect shape4: Qt.rect(0, 0, 0, 0)
    property rect shape5: Qt.rect(0, 0, 0, 0)
    property rect shape6: Qt.rect(0, 0, 0, 0)
    property rect shape7: Qt.rect(0, 0, 0, 0)

    property real radius0: 0
    property real radius1: 0
    property real radius2: 0
    property real radius3: 0
    property real radius4: 0
    property real radius5: 0
    property real radius6: 0
    property real radius7: 0

    ShaderEffect {
        anchors.fill: parent

        property vector2d surfaceSize: Qt.vector2d(root.width, root.height)
        property real edgeOffset: root.edgeOffset
        property real connectionRadius: root.connectionRadius
        property int shapeCount: Math.min(root.shapeCount, root.maximumShapeCount)

        property rect shape0: root.shape0
        property rect shape1: root.shape1
        property rect shape2: root.shape2
        property rect shape3: root.shape3
        property rect shape4: root.shape4
        property rect shape5: root.shape5
        property rect shape6: root.shape6
        property rect shape7: root.shape7

        property real radius0: root.radius0
        property real radius1: root.radius1
        property real radius2: root.radius2
        property real radius3: root.radius3
        property real radius4: root.radius4
        property real radius5: root.radius5
        property real radius6: root.radius6
        property real radius7: root.radius7

        property color liquidColor: root.color

        fragmentShader: Qt.resolvedUrl("../../shaders/sdf-liquid.frag.qsb")
    }
}
