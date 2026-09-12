import Quickshell
import Quickshell.Widgets
import QtQuick
import "../../components/theme"
import "../../services"
import "../overview"

Item {
    id: root

    property bool shown: false
    property real maximumWidth: 1
    required property Item wallpaperSourceItem
    required property rect wallpaperRect
    readonly property int itemSize: 48
    readonly property int padding: 10
    readonly property int dockHeight: itemSize + padding * 2
    readonly property bool hasApplications: applicationModel.values.length > 0

    width: Math.min(maximumWidth, applicationRow.contentWidth + padding * 2)
    height: dockHeight
    visible: hasApplications && (shown || opacity > 0)
    opacity: shown && hasApplications ? 1 : 0
    scale: shown && hasApplications ? 1 : 0.92

    function normalizedId(value): string {
        return (value || "").toString().toLowerCase()
            .replace(/\.desktop$/, "");
    }

    function isNewer(first, second): bool {
        const firstTime = first.focus_timestamp || {};
        const secondTime = second.focus_timestamp || {};
        if ((firstTime.secs || 0) !== (secondTime.secs || 0))
            return (firstTime.secs || 0) > (secondTime.secs || 0);
        return (firstTime.nanos || 0) > (secondTime.nanos || 0);
    }

    function desktopEntryFor(appId): var {
        const target = normalizedId(appId);
        const applications = [...DesktopEntries.applications.values];
        return applications.find(application => {
            const id = normalizedId(application.id);
            const startupClass = normalizedId(application.startupWMClass);
            return id === target || startupClass === target
                || id.endsWith("." + target);
        }) || null;
    }

    Behavior on opacity {
        NumberAnimation {
            duration: ShellMetrics.fastAnimationMs
            easing.type: Easing.InOutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: ShellMetrics.fastAnimationMs
            easing.type: Easing.OutCubic
        }
    }

    ScriptModel {
        id: applicationModel
        objectProp: "key"

        values: {
            const groups = {};
            NiriService.windows.forEach(window => {
                const key = root.normalizedId(window.app_id)
                    || "window-" + window.id;
                const current = groups[key];
                if (!current || root.isNewer(window, current.window))
                    groups[key] = { key: key, appId: window.app_id,
                        window: window };
            });

            return Object.values(groups).map(group => {
                const application = root.desktopEntryFor(group.appId);
                return Object.assign({}, group, {
                    name: application ? application.name
                        : (group.appId || group.window.title),
                    icon: application ? application.icon : ""
                });
            }).sort((first, second) => first.name.localeCompare(second.name));
        }
    }

    OverviewCardBackground {
        anchors.fill: parent
        wallpaperSourceItem: root.wallpaperSourceItem
        wallpaperRect: root.wallpaperRect
    }

    ListView {
        id: applicationRow

        anchors {
            fill: parent
            margins: root.padding
        }
        orientation: ListView.Horizontal
        spacing: 6
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: applicationModel

        delegate: Item {
            id: applicationItem

            required property var modelData
            width: root.itemSize
            height: root.itemSize

            Rectangle {
                anchors.fill: parent
                radius: ShellMetrics.radiusMedium
                color: itemHover.hovered
                    ? Theme.hoverSurfaceColor : "transparent"

                Behavior on color {
                    ColorAnimation { duration: ShellMetrics.fastAnimationMs }
                }
            }

            IconImage {
                anchors.centerIn: parent
                implicitSize: 34
                source: Quickshell.iconPath(applicationItem.modelData.icon,
                    "application-x-executable")
                asynchronous: true

                scale: itemHover.hovered ? 1.1 : 1
                Behavior on scale {
                    NumberAnimation {
                        duration: ShellMetrics.fastAnimationMs
                        easing.type: Easing.OutCubic
                    }
                }
            }

            HoverHandler {
                id: itemHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: NiriService.focusWindow(
                    applicationItem.modelData.window.id)
            }
        }
    }
}
