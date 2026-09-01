import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import "../services"

PanelWindow {
    id: root

    required property var modelData

    property url displayedSource: ""
    property url incomingSource: ""
    property bool transitionQueued: false
    property real revealCenterX: 0
    property real revealCenterY: 0
    property real revealRadius: 0
    property real maximumRevealRadius: 0
    property real margin: 0
    property real cornerRadius: 28
    property int imageFillMode: Image.PreserveAspectCrop

    function queueWallpaper(nextSource): void {
        if (nextSource.toString() === displayedSource.toString())
            return;

        incomingSource = nextSource;
        transitionQueued = true;
        if (incomingImage.status === Image.Ready)
            startReveal();
    }

    function startReveal(): void {
        revealCenterX = Math.random() * wallpaperFrame.width;
        revealCenterY = Math.random() * wallpaperFrame.height;

        const horizontalDistance = Math.max(revealCenterX,
            wallpaperFrame.width - revealCenterX);
        const verticalDistance = Math.max(revealCenterY,
            wallpaperFrame.height - revealCenterY);
        maximumRevealRadius = Math.sqrt(horizontalDistance * horizontalDistance
            + verticalDistance * verticalDistance) + 2;
        revealRadius = 0;
        revealAnimation.restart();
    }

    Component.onCompleted: displayedSource = WallpaperService.source

    Connections {
        target: WallpaperService

        function onSourceChanged() {
            root.queueWallpaper(WallpaperService.source);
        }
    }

    screen: modelData
    color: Theme.wallpaperFallbackColor
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "wallpaper"

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    mask: Region {}

    ClippingRectangle {
        id: wallpaperFrame

        anchors.fill: parent
        anchors.margins: root.margin
        radius: root.cornerRadius
        color: Theme.wallpaperFallbackColor
        contentUnderBorder: true

        Image {
            anchors.fill: parent
            source: root.displayedSource
            fillMode: root.imageFillMode
            asynchronous: true
            cache: true
            smooth: true
            mipmap: true
        }

        Image {
            id: incomingImage

            anchors.fill: parent
            source: root.incomingSource
            fillMode: root.imageFillMode
            asynchronous: true
            cache: true
            smooth: true
            mipmap: true

            onStatusChanged: {
                if (status === Image.Ready && root.transitionQueued)
                    root.startReveal();
            }
        }

        ShaderEffectSource {
            id: incomingTexture
            anchors.fill: parent
            visible: false
            sourceItem: incomingImage
            hideSource: true
            live: true
            smooth: true
        }

        ShaderEffect {
            anchors.fill: parent
            visible: root.transitionQueued

            property var source: incomingTexture
            property vector2d surfaceSize: Qt.vector2d(width, height)
            property vector2d revealCenter: Qt.vector2d(
                root.revealCenterX, root.revealCenterY)
            property real revealRadius: root.revealRadius
            property real edgeSoftness: 3

            fragmentShader: Qt.resolvedUrl("../shaders/wallpaper-reveal.frag.qsb")
        }
    }

    NumberAnimation {
        id: revealAnimation

        target: root
        property: "revealRadius"
        from: 0
        to: root.maximumRevealRadius
        duration: 1400
        easing.type: Easing.InOutCubic

        onFinished: {
            root.displayedSource = root.incomingSource;
            root.transitionQueued = false;
        }
    }
}
