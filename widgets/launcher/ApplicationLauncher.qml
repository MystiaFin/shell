import Quickshell
import Quickshell.Widgets
import QtQuick
import "../../components/theme"

Item {
    id: root

    property bool shown: false
    property real maximumHeight: 620
    property real resultRowHeight: 60
    property real fixedContentHeight: 122
    property real bottomPadding: ShellMetrics.panelContentInsetFromEdge
    property int previousResultCount: 0

    readonly property real minimumHeight: fixedContentHeight + resultRowHeight
    readonly property real desiredHeight: Math.min(
        maximumHeight,
        Math.max(
            minimumHeight,
            fixedContentHeight
                + filteredApplications.values.length * resultRowHeight
        )
    )
    readonly property int resizeDurationMs: Math.min(
        700,
        340 + Math.abs(
            filteredApplications.values.length - previousResultCount
        ) * 24
    )
    property alias focusTarget: searchInput

    signal closeRequested()

    function launchCurrentApplication(): void {
        if (applicationList.currentItem)
            applicationList.currentItem.launch();
    }

    ScriptModel {
        id: filteredApplications

        values: {
            const query = searchInput.text.trim().toLowerCase();
            const applications = [...DesktopEntries.applications.values];
            const matches = query.length === 0
                ? applications
                : applications.filter(application => {
                    const searchable = [
                        application.name,
                        application.genericName,
                        application.comment,
                        ...application.keywords
                    ].join(" ").toLowerCase();

                    return searchable.includes(query);
                });

            return matches.sort((first, second) =>
                first.name.localeCompare(second.name));
        }
    }

    Rectangle {
        id: searchBackground
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            bottomMargin: root.bottomPadding
            leftMargin: 14
            rightMargin: 14
        }
        height: 46
        radius: 14
        color: Theme.panelSurfaceColor

        TextInput {
            id: searchInput
            anchors {
                fill: parent
                leftMargin: 14
                rightMargin: 14
            }
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.primaryTextColor
            selectionColor: Theme.selectedSurfaceColor
            selectedTextColor: Theme.primaryTextColor
            font.pixelSize: 15
            font.family: Typography.bodyFontFamily
            clip: true

            Keys.onDownPressed: {
                if (applicationList.count > 0) {
                    applicationList.incrementCurrentIndex();
                    applicationList.positionViewAtIndex(
                        applicationList.currentIndex,
                        ListView.Contain
                    );
                }
            }
            Keys.onUpPressed: {
                if (applicationList.count > 0) {
                    applicationList.decrementCurrentIndex();
                    applicationList.positionViewAtIndex(
                        applicationList.currentIndex,
                        ListView.Contain
                    );
                }
            }
            Keys.onReturnPressed: root.launchCurrentApplication()
            Keys.onEnterPressed: root.launchCurrentApplication()
            Keys.onEscapePressed: root.closeRequested()

            onTextChanged: {
                root.previousResultCount = applicationList.count;
                Qt.callLater(() => {
                    applicationList.currentIndex = applicationList.count > 0 ? 0 : -1;
                    if (applicationList.currentIndex >= 0)
                        applicationList.positionViewAtBeginning();
                });
            }
        }

        Text {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 14
            }
            visible: searchInput.text.length === 0
            text: "Search applications..."
            color: Theme.mutedTextColor
            font.pixelSize: 15
            font.family: Typography.bodyFontFamily
        }
    }

    ListView {
        id: applicationList
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: searchBackground.top
            topMargin: 12
            leftMargin: 14
            rightMargin: 14
            bottomMargin: 8
        }

        model: filteredApplications
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        reuseItems: true
        currentIndex: count > 0 ? 0 : -1
        keyNavigationWraps: true

        highlightMoveDuration: 100
        highlight: Rectangle {
            radius: 14
            color: Theme.selectedSurfaceColor
        }

        delegate: ApplicationResultDelegate {
            required property var modelData
            required property int index

            readonly property var applicationEntry: modelData

            width: applicationList.width
            height: root.resultRowHeight
            application: applicationEntry
            selected: ListView.isCurrentItem
            onHoverRequested: applicationList.currentIndex = index
            onLaunchRequested: {
                applicationEntry.execute();
                root.closeRequested();
            }
        }
    }

    Text {
        anchors.centerIn: applicationList
        visible: applicationList.count === 0
        text: "No applications found"
        color: Theme.secondaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 14
    }

    onShownChanged: {
        if (shown) {
            searchInput.clear();
            applicationList.currentIndex = applicationList.count > 0 ? 0 : -1;
        }
    }
}
