import QtQuick
import "../../components/common"
import "../../components/state"
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property bool shown
    required property int requestSerial

    property string section: "animations"
    property string pendingIntegration: ""
    property string pendingTitle: ""
    property string pendingWarning: ""

    readonly property var animationSettings: [
        { key: "panel", title: "Panels", detail: "Control, utility, power, and edge panels" },
        { key: "launcher", title: "Launcher", detail: "Results, selection, and scrolling" },
        { key: "content", title: "Content", detail: "Calendar, connectivity, media, and switches" },
        { key: "notification", title: "Notifications", detail: "Popup and history movement; timeout remains active" },
        { key: "wallpaper", title: "Wallpaper", detail: "Startup and wallpaper reveal" },
        { key: "statusBar", title: "Status bar", detail: "Startup and workspace movement" },
        { key: "floatingWidget", title: "Floating widgets", detail: "Overview fade and card repositioning" }
    ]

    readonly property var integrationSettings: [
        { key: "gtk", title: "GTK", detail: "GTK 3/4 and desktop preferences", warning: "This writes generated GTK themes, changes gtk-theme, icon-theme and color-scheme through dconf, replaces ~/.config/gtk-4.0/gtk.css with a symlink, and restarts xdg-desktop-portal-gnome." },
        { key: "terminal", title: "Terminals", detail: "Kitty and foot", warning: "This overwrites Quickshell kitty and foot palette files, reloads kitty windows, signals all running foot processes, and writes color escape sequences to matching terminal TTYs." },
        { key: "tmux", title: "tmux", detail: "Status line and pane colors", warning: "This overwrites tmux-colors.conf and asks running tmux servers to source that file." },
        { key: "vesktop", title: "Vesktop", detail: "Vencord Quick CSS", warning: "This edits ~/.config/vesktop/settings/quickCss.css. Content outside the managed quickshell-theme marker is preserved, but the file itself is rewritten." },
        { key: "spotify", title: "Spotify", detail: "Spicetify color stylesheet", warning: "This creates and overwrites the Quickshell Spotify stylesheet under your cache directory." },
        { key: "btop", title: "btop", detail: "Generated terminal monitor theme", warning: "This creates and overwrites ~/.config/btop/themes/quickshell.theme." },
        { key: "cava", title: "Cava", detail: "Generated visualizer theme", warning: "This creates and overwrites ~/.config/cava/themes/quickshell." }
    ]

    readonly property var widgetSettings: [
        { key: "clockWidget", title: "Clock", detail: "Large desktop clock" },
        { key: "weatherWidget", title: "Weather", detail: "Current weather summary" },
        { key: "calendarWidget", title: "Calendar", detail: "Monthly calendar" },
        { key: "cpuTemperatureWidget", title: "CPU temperature", detail: "Processor thermal card" },
        { key: "cpuUsageWidget", title: "CPU usage", detail: "Processor utilization card" },
        { key: "gpuTemperatureWidget", title: "GPU temperature", detail: "Shown only when a supported GPU is available" },
        { key: "uvIndexWidget", title: "UV index", detail: "Requires configured weather data" },
        { key: "humidityWidget", title: "Humidity", detail: "Requires configured weather data" },
        { key: "airQualityWidget", title: "Air quality", detail: "Shown only when air-quality data is available" }
    ]

    readonly property string sectionTitle: section === "animations"
        ? "Animations"
        : section === "integrations"
            ? "Color integrations"
            : "Floating widgets"

    readonly property string sectionDescription: section === "animations"
        ? "Tune how each part of the shell moves."
        : section === "integrations"
            ? "Keep supported applications in sync with the current shell palette."
            : "Choose which cards are allowed to appear on the desktop."

    opacity: shown ? 1 : 0

    Behavior on opacity {
        MotionAnimation { type: MotionAnimation.DefaultEffects }
    }

    function requestIntegration(name, title, warning): void {
        const key = name + "Integration";
        if (SettingsService[key]) {
            SettingsService.setValue(key, false);
            return;
        }

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

    Rectangle {
        anchors.fill: parent
        color: Theme.shellBackgroundColor
    }

    Item {
        id: keyHandler
        anchors.fill: parent
        focus: root.shown

        Keys.onEscapePressed: {
            if (root.pendingIntegration)
                root.pendingIntegration = "";
            else
                OverlayState.hideSettings();
        }
    }

    Item {
        anchors {
            fill: parent
            margins: 22
        }

        Row {
            id: header

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 52
            spacing: 12

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                height: 40
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

                Text {
                    text: "Settings"
                    color: Theme.primaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 21
                    font.weight: Font.Bold
                }

                Text {
                    text: "Quickshell"
                    color: Theme.mutedTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 10
                }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                height: 40
                radius: ShellMetrics.radiusMedium
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: Icons.close
                    color: Theme.secondaryTextColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 18
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler { onTapped: OverlayState.hideSettings() }
            }
        }

        SettingsNavigation {
            id: sidebar

            anchors {
                top: header.bottom
                left: parent.left
                bottom: parent.bottom
                topMargin: 16
            }
            width: 202
            currentSection: root.section
            onSectionRequested: section => root.section = section
        }

        Item {
            id: contentArea

            anchors {
                top: header.bottom
                left: sidebar.right
                right: parent.right
                bottom: parent.bottom
                topMargin: 16
                leftMargin: 22
            }

            Column {
                id: sectionHeader

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                spacing: 2

                Text {
                    width: parent.width
                    text: root.sectionTitle
                    color: Theme.primaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 20
                    font.weight: Font.Bold
                }

                Text {
                    width: parent.width
                    text: root.sectionDescription
                    color: Theme.mutedTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }
            }

            Flickable {
                id: scroller

                anchors {
                    top: sectionHeader.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    topMargin: 16
                }
                contentHeight: sectionSurface.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Rectangle {
                    id: sectionSurface

                    width: scroller.width
                    height: settingsRows.implicitHeight
                    radius: ShellMetrics.radiusExtraLarge
                    color: Theme.panelSurfaceColor
                    clip: true

                    Column {
                        id: settingsRows
                        width: parent.width

                        Repeater {
                            model: root.section === "animations"
                                ? root.animationSettings : []

                            delegate: SettingsAnimationRow {
                                required property var modelData
                                required property int index

                                width: settingsRows.width
                                groupKey: modelData.key
                                title: modelData.title
                                detail: modelData.detail
                                showSeparator: index < root.animationSettings.length - 1
                            }
                        }

                        Repeater {
                            model: root.section === "integrations"
                                ? root.integrationSettings : []

                            delegate: SettingsToggleRow {
                                required property var modelData
                                required property int index

                                width: settingsRows.width
                                title: modelData.title
                                detail: modelData.detail
                                checked: SettingsService[modelData.key + "Integration"]
                                showSeparator: index < root.integrationSettings.length - 1
                                onToggleRequested: root.requestIntegration(
                                    modelData.key,
                                    modelData.title,
                                    modelData.warning)
                            }
                        }

                        Repeater {
                            model: root.section === "widgets"
                                ? root.widgetSettings : []

                            delegate: SettingsToggleRow {
                                required property var modelData
                                required property int index

                                width: settingsRows.width
                                title: modelData.title
                                detail: modelData.detail
                                checked: SettingsService[modelData.key]
                                showSeparator: index < root.widgetSettings.length - 1
                                onToggleRequested: SettingsService.setValue(
                                    modelData.key, !checked)
                            }
                        }
                    }
                }
            }
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

                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: 22
                }
                spacing: 12

                Row {
                    width: parent.width
                    spacing: 12

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 38
                        height: 38
                        radius: ShellMetrics.radiusMedium
                        color: Theme.selectedSurfaceColor

                        Text {
                            anchors.centerIn: parent
                            text: "󰀪"
                            color: Theme.dangerColor
                            font.family: Typography.nerdIconFontFamily
                            font.pixelSize: 20
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 50
                        text: "Enable " + root.pendingTitle + " integration?"
                        color: Theme.primaryTextColor
                        font.family: Typography.bodyFontFamily
                        font.pixelSize: 17
                        font.weight: Font.Bold
                        wrapMode: Text.WordWrap
                    }
                }

                Text {
                    width: parent.width
                    text: root.pendingWarning
                    color: Theme.secondaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                    lineHeight: 1.2
                }

                Text {
                    width: parent.width
                    text: "Only continue if you have reviewed and backed up the affected configuration."
                    color: Theme.mutedTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }

                Row {
                    anchors.right: parent.right
                    spacing: 8

                    SettingsActionButton {
                        label: "Cancel"
                        onClicked: root.pendingIntegration = ""
                    }

                    SettingsActionButton {
                        label: "Enable"
                        danger: true
                        onClicked: root.confirmIntegration()
                    }
                }
            }
        }
    }

    onRequestSerialChanged: {
        if (shown)
            Qt.callLater(() => keyHandler.forceActiveFocus());
    }

    onShownChanged: {
        if (shown)
            Qt.callLater(() => keyHandler.forceActiveFocus());
    }
}
