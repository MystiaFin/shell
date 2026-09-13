import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../components/common"
import "../../components/state"
import "../../components/theme"
import "../../services"

PanelWindow {
    id: root

    required property var modelData
    readonly property var targetScreen: modelData
    readonly property bool bottomPosition: SettingsService.statusBarPosition === "bottom"
    readonly property real fullHeight: ShellMetrics.statusBarHeight
    readonly property real peekHeight: Math.max(3, 4 * SettingsService.uiScale)

    property date now: new Date()
    property real backgroundOpacity: 0
    property bool backgroundFadeStarted: false
    property bool introStarted: false
    property bool autoHideRevealed: !SettingsService.statusBarAutoHide

    function startBackgroundFade(): void {
        if (backgroundFadeStarted || !StartupState.sequenceStarted(targetScreen.name))
            return;
        backgroundFadeStarted = true;
        backgroundFade.start();
    }

    function startIntro(): void {
        if (introStarted || !StartupState.maskRevealFinished(targetScreen.name))
            return;
        introStarted = true;
        statusContent.introOffset = root.bottomPosition
            ? statusContent.height : -statusContent.height;
        statusIntro.start();
    }

    function revealForHover(): void {
        hideTimer.stop();
        autoHideRevealed = true;
    }

    Component.onCompleted: {
        startBackgroundFade();
        startIntro();
    }

    screen: targetScreen
    color: "transparent"
    implicitHeight: SettingsService.statusBarAutoHide && !autoHideRevealed
        ? peekHeight : fullHeight
    exclusiveZone: SettingsService.statusBarAutoHide ? 0 : fullHeight

    anchors {
        top: !root.bottomPosition
        bottom: root.bottomPosition
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "status-bar"

    Connections {
        target: StartupState
        function onStartedScreensChanged(): void { root.startBackgroundFade(); }
        function onRevealedScreensChanged(): void { root.startIntro(); }
    }

    Connections {
        target: SettingsService
        function onStatusBarAutoHideChanged(): void {
            root.autoHideRevealed = !SettingsService.statusBarAutoHide;
        }
        function onStatusBarPositionChanged(): void {
            root.introStarted = false;
            root.startIntro();
        }
    }

    HoverHandler {
        id: barHover
        onHoveredChanged: {
            OverlayState.statusBarHovered = hovered;
            if (!SettingsService.statusBarAutoHide)
                return;
            if (hovered)
                root.revealForHover();
            else
                hideTimer.restart();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.backgroundOpacity
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.shellBackgroundColor
        opacity: root.backgroundOpacity
        topLeftRadius: root.bottomPosition ? 0 : ShellMetrics.radiusLarge
        topRightRadius: root.bottomPosition ? 0 : ShellMetrics.radiusLarge
        bottomLeftRadius: root.bottomPosition ? ShellMetrics.radiusLarge : 0
        bottomRightRadius: root.bottomPosition ? ShellMetrics.radiusLarge : 0

        Item {
            id: statusContent
            property real introOffset: 0
            width: parent.width
            height: root.fullHeight
            y: (parent.height - height) / 2 + introOffset

            StatusBarWorkspaceSection {
                outputName: root.screen.name
                anchors {
                    left: parent.left
                    leftMargin: 20 * SettingsService.uiScale
                    verticalCenter: parent.verticalCenter
                }
            }

            StatusBarCenterSection {
                currentTime: root.now
                anchors.centerIn: parent
            }

            StatusBarSystemSection {
                anchors {
                    right: parent.right
                    rightMargin: 15 * SettingsService.uiScale
                    verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    MotionAnimation {
        id: backgroundFade
        group: "statusBar"
        type: MotionAnimation.DefaultEffects
        target: root
        property: "backgroundOpacity"
        from: 0
        to: 1
    }

    MotionAnimation {
        id: statusIntro
        group: "statusBar"
        target: statusContent
        property: "introOffset"
        to: 0
    }

    Timer {
        id: hideTimer
        interval: 450
        onTriggered: {
            if (SettingsService.statusBarAutoHide && !barHover.hovered)
                root.autoHideRevealed = false;
        }
    }

    Timer {
        interval: SettingsService.clockShowSeconds ? 1000 : 15000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
