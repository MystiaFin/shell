import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import "../../services"
import "../theme"

PanelWindow {
    id: root

    required property var modelData
    readonly property var targetScreen: modelData

    property url displayedSource: ""
    property url pendingSource: ""
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

        pendingSource = nextSource;
        revealDelay.restart();
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

    screen: targetScreen
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

            fragmentShader: Qt.resolvedUrl("../../shaders/wallpaper-reveal.frag.qsb")
        }
    }

    ClippingRectangle {
        anchors {
            top: parent.top
            topMargin: ShellMetrics.statusBarHeight
            right: parent.right
            bottom: parent.bottom
            left: parent.left
        }
        radius: 18
        color: "transparent"

        Rectangle {
            anchors {
                top: parent.top
                right: parent.right
                left: parent.left
            }
            height: 8
            gradient: Gradient {
                GradientStop { position: 0; color: "#30000000" }
                GradientStop { position: 0.45; color: "#14000000" }
                GradientStop { position: 1; color: "transparent" }
            }
        }
    }

    Timer {
        id: revealDelay

        interval: 200
        repeat: false
        onTriggered: {
            root.incomingSource = root.pendingSource;
            root.revealRadius = 0;
            root.transitionQueued = true;
            if (incomingImage.status === Image.Ready)
                root.startReveal();
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
