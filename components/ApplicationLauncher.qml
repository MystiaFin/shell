import Quickshell
import Quickshell.Widgets
import QtQuick

Item {
    id: root

    property bool shown: false
    property real maximumHeight: 620
    property real rowHeight: 60
    property real chromeHeight: 122
    property real bottomPadding: LiquidMetrics.edgeContentInset
    property int resizeSourceCount: 0

    readonly property real minimumHeight: chromeHeight + rowHeight
    readonly property real desiredHeight: Math.min(
        maximumHeight,
        Math.max(
            minimumHeight,
            chromeHeight + filteredApplications.values.length * rowHeight
        )
    )
    readonly property int resizeDuration: Math.min(
        700,
        340 + Math.abs(
            filteredApplications.values.length - resizeSourceCount
        ) * 24
    )
    property alias focusTarget: searchInput

    signal closeRequested()

    function launchCurrentApplication(): void {
        if (applicationList.currentItem)
            applicationList.currentItem.launchApplication();
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
        color: Theme.launcherSearchBackgroundColor

        TextInput {
            id: searchInput
            anchors {
                fill: parent
                leftMargin: 14
                rightMargin: 14
            }
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.launcherTextColor
            selectionColor: Theme.launcherSelectionColor
            selectedTextColor: Theme.launcherTextColor
            font.pixelSize: 15
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
                root.resizeSourceCount = applicationList.count;
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
            color: Theme.launcherPlaceholderTextColor
            font.pixelSize: 15
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
            color: Theme.launcherSelectionColor
        }

        delegate: Item {
            id: applicationDelegate

            required property var modelData
            required property int index

            width: applicationList.width
            height: root.rowHeight

            function launchApplication(): void {
                modelData.execute();
                root.closeRequested();
            }

            IconImage {
                id: applicationIcon
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }
                implicitSize: 38
                source: Quickshell.iconPath(
                    applicationDelegate.modelData.icon,
                    "application-x-executable"
                )
                asynchronous: true
            }

            Text {
                anchors {
                    left: applicationIcon.right
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                    rightMargin: 12
                }
                text: applicationDelegate.modelData.name
                color: Theme.launcherTextColor
                font.pixelSize: 15
                font.weight: applicationDelegate.ListView.isCurrentItem
                    ? Font.DemiBold
                    : Font.Normal
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onEntered: applicationList.currentIndex = applicationDelegate.index
                onClicked: {
                    applicationList.currentIndex = applicationDelegate.index;
                    applicationDelegate.launchApplication();
                }
            }
        }
    }

    Text {
        anchors.centerIn: applicationList
        visible: applicationList.count === 0
        text: "No applications found"
        color: Theme.launcherSecondaryTextColor
        font.pixelSize: 14
    }

    onShownChanged: {
        if (shown) {
            searchInput.clear();
            applicationList.currentIndex = applicationList.count > 0 ? 0 : -1;
        }
    }
}
