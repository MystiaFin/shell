import QtQuick
import "../../components/common"
import "../../components/state"
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property bool shown
    required property int requestSerial

    property string section: "appearance"
    property string pendingIntegration: ""
    property string pendingTitle: ""
    property string pendingWarning: ""
    property bool pendingReset: false

    readonly property var sectionMeta: ({
        appearance: { title: "Appearance", description: "Tune the shell's surfaces, scale, blur, and roundedness." },
        colors: { title: "Colors", description: "Control palette selection and how dynamic wallpaper colors are generated." },
        launcher: { title: "Launcher", description: "Configure search results, command mode, and launcher presentation." },
        wallpaper: { title: "Wallpaper", description: "Choose the source directory, transitions, shuffle, and palette behavior." },
        bar: { title: "Status bar", description: "Control placement, modules, clock formatting, and workspace presentation." },
        behavior: { title: "Behavior", description: "Change dismissal rules, launcher behavior, and global motion preferences." },
        widgets: { title: "Floating widgets", description: "Control desktop-only visibility, placement, scale, opacity, and cards." },
        animations: { title: "Animations", description: "Tune motion style and duration for each part of the shell." },
        integrations: { title: "Integrations", description: "Keep supported applications in sync with the current shell palette." },
        about: { title: "About", description: "Inspect the running setup, open the config, reload, or reset settings." }
    })
    readonly property var currentMeta: sectionMeta[section] || sectionMeta.appearance

    opacity: shown ? 1 : 0
    Behavior on opacity { MotionAnimation { type: MotionAnimation.DefaultEffects } }

    function pageSource(sectionKey): url {
        switch (sectionKey) {
        case "appearance": return Qt.resolvedUrl("pages/AppearanceSettings.qml");
        case "colors": return Qt.resolvedUrl("pages/ColorsSettings.qml");
        case "launcher": return Qt.resolvedUrl("pages/LauncherSettings.qml");
        case "wallpaper": return Qt.resolvedUrl("pages/WallpaperSettings.qml");
        case "bar": return Qt.resolvedUrl("pages/BarSettings.qml");
        case "behavior": return Qt.resolvedUrl("pages/BehaviorSettings.qml");
        case "widgets": return Qt.resolvedUrl("pages/FloatingWidgetsSettings.qml");
        case "animations": return Qt.resolvedUrl("pages/AnimationsSettings.qml");
        case "integrations": return Qt.resolvedUrl("pages/IntegrationsSettings.qml");
        case "about": return Qt.resolvedUrl("pages/AboutSettings.qml");
        }
        return Qt.resolvedUrl("pages/AppearanceSettings.qml");
    }

    function requestIntegration(name, title, warning): void {
        pendingIntegration = name;
        pendingTitle = title;
        pendingWarning = warning;
    }

    function confirmIntegration(): void {
        if (!pendingIntegration)
            return;
        SettingsService.setValue(pendingIntegration + "Integration", true);
        pendingIntegration = "";
    }

    Rectangle { anchors.fill: parent; color: Theme.shellBackgroundColor }

    Item {
        id: keyHandler
        anchors.fill: parent
        focus: root.shown
        Keys.onEscapePressed: {
            if (root.pendingIntegration)
                root.pendingIntegration = "";
            else if (root.pendingReset)
                root.pendingReset = false;
            else
                OverlayState.hideSettings();
        }
    }

    Item {
        anchors { fill: parent; margins: 22 }

        Row {
            id: header
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 52
            spacing: 12

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 40; height: 40
                radius: ShellMetrics.radiusMedium
                color: Theme.selectedSurfaceColor
                Text {
                    anchors.centerIn: parent
                    text: Icons.settings
                    color: Theme.accentColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 21
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 104
                spacing: 0
                Text { text: "Settings"; color: Theme.primaryTextColor; font.family: Typography.bodyFontFamily; font.pixelSize: 21; font.weight: Font.Bold }
                Text { text: "Quickshell"; color: Theme.mutedTextColor; font.family: Typography.bodyFontFamily; font.pixelSize: 10 }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 40; height: 40
                radius: ShellMetrics.radiusMedium
                color: "transparent"
                Text { anchors.centerIn: parent; text: Icons.close; color: Theme.secondaryTextColor; font.family: Typography.nerdIconFontFamily; font.pixelSize: 18 }
                HoverHandler { cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: OverlayState.hideSettings() }
            }
        }

        SettingsNavigation {
            id: sidebar
            anchors { top: header.bottom; left: parent.left; bottom: parent.bottom; topMargin: 16 }
            width: 218
            currentSection: root.section
            onSectionRequested: section => {
                root.section = section;
                scroller.contentY = 0;
            }
        }

        Item {
            id: contentArea
            anchors { top: header.bottom; left: sidebar.right; right: parent.right; bottom: parent.bottom; topMargin: 16; leftMargin: 22 }

            Column {
                id: sectionHeader
                anchors { top: parent.top; left: parent.left; right: parent.right }
                spacing: 2
                Text { width: parent.width; text: root.currentMeta.title; color: Theme.primaryTextColor; font.family: Typography.bodyFontFamily; font.pixelSize: 20; font.weight: Font.Bold }
                Text { width: parent.width; text: root.currentMeta.description; color: Theme.mutedTextColor; font.family: Typography.bodyFontFamily; font.pixelSize: 11; wrapMode: Text.WordWrap }
            }

            Flickable {
                id: scroller
                anchors { top: sectionHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; topMargin: 16 }
                contentHeight: sectionLoader.item ? sectionLoader.item.implicitHeight : 0
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Loader {
                    id: sectionLoader
                    width: scroller.width
                    height: item ? item.implicitHeight : 0
                    source: root.pageSource(root.section)
                }
            }
        }
    }

    Connections {
        target: sectionLoader.item
        ignoreUnknownSignals: true
        function onIntegrationRequested(name, title, warning): void {
            root.requestIntegration(name, title, warning);
        }
        function onResetRequested(): void {
            root.pendingReset = true;
        }
    }

    Rectangle {
        visible: root.pendingIntegration !== ""
        anchors.fill: parent
        color: "#8c000000"
        z: 20
        TapHandler { }

        Rectangle {
            anchors.centerIn: parent
            width: Math.min(500, parent.width - 40)
            height: warningContent.implicitHeight + 44
            radius: ShellMetrics.radiusExtraLarge
            color: Theme.panelSurfaceColor

            Column {
                id: warningContent
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 22 }
                spacing: 12
                Row {
                    width: parent.width; spacing: 12
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 38; height: 38; radius: ShellMetrics.radiusMedium; color: Theme.selectedSurfaceColor
                        Text { anchors.centerIn: parent; text: "󰀪"; color: Theme.dangerColor; font.family: Typography.nerdIconFontFamily; font.pixelSize: 20 }
                    }
                    Text { anchors.verticalCenter: parent.verticalCenter; width: parent.width - 50; text: "Enable " + root.pendingTitle + " integration?"; color: Theme.primaryTextColor; font.family: Typography.bodyFontFamily; font.pixelSize: 17; font.weight: Font.Bold; wrapMode: Text.WordWrap }
                }
                Text { width: parent.width; text: root.pendingWarning; color: Theme.secondaryTextColor; font.family: Typography.bodyFontFamily; font.pixelSize: 11; wrapMode: Text.WordWrap; lineHeight: 1.2 }
                Text { width: parent.width; text: "Only continue if you have reviewed and backed up the affected configuration."; color: Theme.mutedTextColor; font.family: Typography.bodyFontFamily; font.pixelSize: 10; wrapMode: Text.WordWrap }
                Row {
                    anchors.right: parent.right; spacing: 8
                    SettingsActionButton { label: "Cancel"; onClicked: root.pendingIntegration = "" }
                    SettingsActionButton { label: "Enable"; danger: true; onClicked: root.confirmIntegration() }
                }
            }
        }
    }

    Rectangle {
        visible: root.pendingReset
        anchors.fill: parent
        color: "#8c000000"
        z: 21
        TapHandler { }

        Rectangle {
            anchors.centerIn: parent
            width: Math.min(460, parent.width - 40)
            height: resetContent.implicitHeight + 44
            radius: ShellMetrics.radiusExtraLarge
            color: Theme.panelSurfaceColor

            Column {
                id: resetContent
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 22 }
                spacing: 12
                Text { width: parent.width; text: "Reset all settings?"; color: Theme.primaryTextColor; font.family: Typography.bodyFontFamily; font.pixelSize: 17; font.weight: Font.Bold }
                Text { width: parent.width; text: "This restores every setting managed by SettingsService to its built-in default. Your other config files are not deleted."; color: Theme.secondaryTextColor; font.family: Typography.bodyFontFamily; font.pixelSize: 11; wrapMode: Text.WordWrap }
                Row {
                    anchors.right: parent.right; spacing: 8
                    SettingsActionButton { label: "Cancel"; onClicked: root.pendingReset = false }
                    SettingsActionButton {
                        label: "Reset"; danger: true
                        onClicked: {
                            SettingsService.resetDefaults();
                            root.pendingReset = false;
                        }
                    }
                }
            }
        }
    }

    onRequestSerialChanged: if (shown) Qt.callLater(() => keyHandler.forceActiveFocus())
    onShownChanged: if (shown) Qt.callLater(() => keyHandler.forceActiveFocus())
}
