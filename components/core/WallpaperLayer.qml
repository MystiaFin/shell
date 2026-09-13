import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import "../../services"
import "../common"
import "../state"
import "../theme"

PanelWindow {
    id: root

    required property var modelData
    readonly property var targetScreen: modelData
    readonly property bool barOnTop: SettingsService.statusBarPosition === "top"
    readonly property real reservedBarHeight: SettingsService.statusBarAutoHide
        ? 0 : ShellMetrics.statusBarHeight

    property url displayedSource: ""
    property url pendingSource: ""
    property url incomingSource: ""
    property bool transitionQueued: false
    property real revealCenterX: 0
    property real revealCenterY: 0
    property real revealRadius: 0
    property real fadeProgress: 0
    property real maximumRevealRadius: 0
    property real margin: 0
    property real cornerRadius: ShellMetrics.desktopFrameRadius
    property int imageFillMode: Image.PreserveAspectCrop
    property bool startupIntroStarted: false

    function startStartupIntro(): void {
        if (startupIntroStarted)
            return;

        startupIntroStarted = true;
        StartupState.startSequence(targetScreen.name);
        startupIntro.start();
    }

    function queueWallpaper(nextSource): void {
        if (nextSource.toString() === displayedSource.toString())
            return;

        if (SettingsService.wallpaperTransitionType === "instant") {
            displayedSource = nextSource;
            incomingSource = "";
            transitionQueued = false;
            DisplayedWallpaperState.setSource(targetScreen.name, displayedSource);
            DisplayedWallpaperState.setTransitioning(targetScreen.name, false);
            return;
        }

        DisplayedWallpaperState.setTransitioning(targetScreen.name, true);
        pendingSource = nextSource;
        revealDelay.restart();
    }

    function finishTransition(): void {
        displayedSource = incomingSource;
        transitionQueued = false;
        fadeProgress = 0;
        DisplayedWallpaperState.setSource(targetScreen.name, displayedSource);
        DisplayedWallpaperState.setTransitioning(targetScreen.name, false);
    }

    function startTransition(): void {
        if (!transitionQueued)
            return;
        if (SettingsService.wallpaperTransitionType === "fade") {
            fadeProgress = 0;
            fadeAnimation.restart();
        } else {
            startReveal();
        }
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
    color: "transparent"
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

    Rectangle {
        id: solidBlock

        anchors.fill: parent
        color: Theme.shellBackgroundColor
        opacity: 0
    }

    ClippingRectangle {
        id: wallpaperFrame

        x: root.margin
        y: root.height
        width: root.width - root.margin * 2
        height: root.height - root.margin * 2
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

            onStatusChanged: {
                if (status === Image.Ready)
                    root.startStartupIntro();
            }
        }

        Image {
            id: incomingImage

            anchors.fill: parent
            source: root.incomingSource
            opacity: SettingsService.wallpaperTransitionType === "fade"
                ? root.fadeProgress : 1
            fillMode: root.imageFillMode
            asynchronous: true
            cache: true
            smooth: true
            mipmap: true

            onStatusChanged: {
                if (status === Image.Ready && root.transitionQueued)
                    root.startTransition();
            }
        }

        ShaderEffectSource {
            id: incomingTexture
            anchors.fill: parent
            visible: false
            sourceItem: incomingImage
            hideSource: SettingsService.wallpaperTransitionType === "circle"
            live: true
            smooth: true
        }

        ShaderEffect {
            anchors.fill: parent
            visible: root.transitionQueued
                && SettingsService.wallpaperTransitionType === "circle"

            property var source: incomingTexture
            property vector2d surfaceSize: Qt.vector2d(width, height)
            property vector2d revealCenter: Qt.vector2d(
                root.revealCenterX, root.revealCenterY)
            property real revealRadius: root.revealRadius
            property real edgeSoftness: 3

            fragmentShader: Qt.resolvedUrl("../../shaders/wallpaper-reveal.frag.qsb")
        }
    }

    ShaderEffect {
        anchors {
            top: parent.top
            topMargin: root.barOnTop ? root.reservedBarHeight : 0
            right: parent.right
            bottom: parent.bottom
            bottomMargin: root.barOnTop ? 0 : root.reservedBarHeight
            left: parent.left
        }

        property vector2d surfaceSize: Qt.vector2d(width, height)
        property real cornerRadius: ShellMetrics.radiusLarge
        property real shadowSize: ShellMetrics.shadowSize
        property color shadowColor: Theme.shellShadowColor

        fragmentShader: Qt.resolvedUrl("../../shaders/inner-shadow.frag.qsb")
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
                root.startTransition();
        }
    }

    SequentialAnimation {
        id: startupIntro

        MotionAnimation {
            group: "wallpaper"
            type: MotionAnimation.DefaultEffects
            target: solidBlock
            property: "opacity"
            from: 0
            to: 1
        }

        MotionAnimation {
            group: "wallpaper"
            target: wallpaperFrame
            property: "y"
            from: root.height
            to: root.margin
        }

        onFinished: {
            StartupState.finishMaskReveal(root.targetScreen.name);
            DisplayedWallpaperState.setSource(root.targetScreen.name,
                root.displayedSource);
        }
    }

    MotionAnimation {
        id: fadeAnimation
        group: "wallpaper"
        type: MotionAnimation.DefaultEffects
        target: root
        property: "fadeProgress"
        from: 0
        to: 1
        onFinished: root.finishTransition()
    }

    MotionAnimation {
        group: "wallpaper"
        id: revealAnimation
        type: MotionAnimation.SlowSpatial

        target: root
        property: "revealRadius"
        from: 0
        to: root.maximumRevealRadius

        onFinished: root.finishTransition()
    }
}
