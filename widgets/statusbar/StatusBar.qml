import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../components/state"
import "../../components/theme"

PanelWindow {
    id: root

    required property var modelData
    readonly property var targetScreen: modelData

    property date now: new Date()
    property real backgroundOpacity: 0
    property bool backgroundFadeStarted: false
    property bool introStarted: false

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
        statusContent.y = -statusContent.height;
        statusIntro.start();
    }

    Component.onCompleted: {
        startBackgroundFade();
        startIntro();
    }

    screen: targetScreen
    color: "transparent"
    implicitHeight: ShellMetrics.statusBarHeight
    exclusiveZone: ShellMetrics.statusBarHeight

    anchors {
        top: true
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

    HoverHandler {
        onHoveredChanged: OverlayState.statusBarHovered = hovered
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
        topLeftRadius: 18
        topRightRadius: 18

        Item {
            id: statusContent

            width: parent.width
            height: parent.height
            y: -height

            StatusBarWorkspaceSection {
                outputName: root.screen.name
                anchors {
                    left: parent.left
                    leftMargin: 20
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
                    rightMargin: 15
                    verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    NumberAnimation {
        id: backgroundFade

        target: root
        property: "backgroundOpacity"
        from: 0
        to: 1
        duration: ShellMetrics.startupBlockFadeDurationMs
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: statusIntro

        target: statusContent
        property: "y"
        to: 0
        duration: ShellMetrics.startupStatusBarDurationMs
        easing.type: Easing.OutCubic
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
