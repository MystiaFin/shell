import QtQuick

Item {
    id: root

    default property alias shapes: shapeLayer.data

    property color color: Theme.liquidColor
    property real effectRadius: 18
    property real threshold: 0.5
    property real edgeSoftness: 0.025
    property real renderScale: 1

    Item {
        id: shapeLayer
        anchors.fill: parent
    }

    ShaderEffectSource {
        id: shapeTexture
        anchors.fill: parent
        visible: false
        sourceItem: shapeLayer
        hideSource: true
        live: true
        smooth: true
        textureSize: Qt.size(
            Math.max(1, Math.ceil(root.width * root.renderScale)),
            Math.max(1, Math.ceil(root.height * root.renderScale))
        )
    }

    ShaderEffect {
        id: horizontalBlur
        anchors.fill: parent

        property var source: shapeTexture
        property vector2d texelSize: Qt.vector2d(1 / Math.max(width, 1), 1 / Math.max(height, 1))
        property real blurRadius: root.effectRadius

        fragmentShader: Qt.resolvedUrl("../shaders/liquid-horizontal.frag.qsb")
    }

    ShaderEffectSource {
        id: blurredTexture
        anchors.fill: parent
        visible: false
        format: ShaderEffectSource.RGBA16F
        sourceItem: horizontalBlur
        hideSource: true
        live: true
        smooth: true
        textureSize: shapeTexture.textureSize
    }

    ShaderEffect {
        anchors.fill: parent

        property var blurredSource: blurredTexture
        property var originalSource: shapeTexture
        property vector2d texelSize: Qt.vector2d(1 / Math.max(width, 1), 1 / Math.max(height, 1))
        property real blurRadius: root.effectRadius
        property real alphaThreshold: root.threshold
        property real edgeSoftness: root.edgeSoftness
        property color liquidColor: root.color

        fragmentShader: Qt.resolvedUrl("../shaders/metaball.frag.qsb")
    }
}
