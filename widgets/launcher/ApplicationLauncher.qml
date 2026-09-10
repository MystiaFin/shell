import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import "../../components/theme"

Item {
    id: root

    property bool shown: false
    property string initialQuery: ""
    property int requestSerial: 0
    property real maximumHeight: 620
    property real resultRowHeight: 60
    property real fixedContentHeight: 122
    property real bottomPadding: ShellMetrics.panelContentInsetFromEdge
    property int previousResultCount: 0
    property var tmuxSessions: []
    property var pendingTmuxSessions: []

    readonly property bool tmuxMode: searchInput.text.startsWith("!")

    readonly property real minimumHeight: fixedContentHeight + resultRowHeight
    readonly property real desiredHeight: Math.min(
        maximumHeight,
        Math.max(
            minimumHeight,
            fixedContentHeight
                + filteredResults.values.length * resultRowHeight
        )
    )
    readonly property int resizeDurationMs: Math.min(
        700,
        340 + Math.abs(
            filteredResults.values.length - previousResultCount
        ) * 24
    )
    property alias focusTarget: searchInput

    signal closeRequested()

    function launchCurrentResult(): void {
        if (resultList.currentItem)
            resultList.currentItem.launch();
    }

    function moveSelection(down: bool): void {
        if (resultList.count === 0)
            return;

        if (down)
            resultList.incrementCurrentIndex();
        else
            resultList.decrementCurrentIndex();

        const itemTop = resultList.currentIndex * root.resultRowHeight;
        const itemBottom = itemTop + root.resultRowHeight;
        let targetY = resultList.contentY;

        if (itemTop < resultList.contentY)
            targetY = itemTop;
        else if (itemBottom > resultList.contentY + resultList.height)
            targetY = itemBottom - resultList.height;

        targetY = Math.max(0, Math.min(
            targetY,
            Math.max(0, resultList.contentHeight - resultList.height)
        ));

        if (targetY !== resultList.contentY) {
            resultScroll.stop();
            resultScroll.from = resultList.contentY;
            resultScroll.to = targetY;
            resultScroll.start();
        }
    }

    function refreshTmuxSessions(): void {
        pendingTmuxSessions = [];
        tmuxSessionReader.running = true;
    }

    function launchTmuxSession(sessionName: string): void {
        const terminal = Quickshell.env("TERMINAL");
        if (terminal.length === 0) {
            console.error("Cannot launch tmux session: TERMINAL is not set");
            return;
        }

        Quickshell.execDetached([
            terminal,
            "--",
            "tmux",
            "attach-session",
            "-t",
            sessionName
        ]);
        root.closeRequested();
    }

    ScriptModel {
        id: filteredResults

        values: {
            if (root.tmuxMode) {
                const query = searchInput.text.slice(1).trim().toLowerCase();
                const matches = query.length === 0
                    ? root.tmuxSessions
                    : root.tmuxSessions.filter(sessionName =>
                        sessionName.toLowerCase().includes(query));

                return matches.map(sessionName => ({
                    tmuxSession: true,
                    name: sessionName
                }));
            }

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
                first.name.localeCompare(second.name)).map(application => ({
                    tmuxSession: false,
                    application: application,
                    name: application.name
                }));
        }
    }

    Process {
        id: tmuxSessionReader

        command: ["tmux", "list-sessions", "-F", "#{session_name}"]
        stdout: SplitParser {
            onRead: data => {
                const sessionName = data.trim();
                if (sessionName.length > 0)
                    root.pendingTmuxSessions = root.pendingTmuxSessions.concat(sessionName);
            }
        }
        onExited: root.tmuxSessions = root.pendingTmuxSessions.sort()
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
        radius: ShellMetrics.radiusMedium
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

            Keys.onDownPressed: root.moveSelection(true)
            Keys.onUpPressed: root.moveSelection(false)
            Keys.onReturnPressed: root.launchCurrentResult()
            Keys.onEnterPressed: root.launchCurrentResult()
            Keys.onEscapePressed: root.closeRequested()

            onTextChanged: {
                root.previousResultCount = resultList.count;
                resultList.hoveredIndex = -1;
                Qt.callLater(() => {
                    resultList.currentIndex = resultList.count > 0 ? 0 : -1;
                    if (resultList.currentIndex >= 0)
                        resultList.positionViewAtBeginning();
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
            text: root.tmuxMode ? "Search tmux sessions..." : "Search applications..."
            color: Theme.mutedTextColor
            font.pixelSize: 15
            font.family: Typography.bodyFontFamily
        }
    }

    ListView {
        id: resultList
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

        model: filteredResults
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        reuseItems: true
        currentIndex: count > 0 ? 0 : -1
        keyNavigationWraps: true
        property int hoveredIndex: -1
        property real hoverHighlightY: 0

        NumberAnimation {
            id: resultScroll

            target: resultList
            property: "contentY"
            duration: ShellMetrics.fastAnimationMs
            easing.type: Easing.InOutCubic
        }

        add: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: ShellMetrics.fastAnimationMs
                easing.type: Easing.OutCubic
            }
        }

        remove: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: ShellMetrics.fastAnimationMs
                easing.type: Easing.InCubic
            }
        }

        highlightFollowsCurrentItem: false
        highlight: Rectangle {
            width: resultList.width
            height: root.resultRowHeight
            y: resultList.currentItem
                ? resultList.currentItem.y
                : 0
            radius: ShellMetrics.radiusMedium
            color: Theme.selectedSurfaceColor
            opacity: resultList.currentItem ? 1 : 0

            Behavior on y {
                NumberAnimation {
                    duration: ShellMetrics.fastAnimationMs
                    easing.type: Easing.InOutCubic
                }
            }
        }

        Rectangle {
            parent: resultList.contentItem
            z: 0.5
            width: resultList.width
            height: root.resultRowHeight
            y: resultList.hoverHighlightY
            radius: ShellMetrics.radiusMedium
            color: Theme.hoverSurfaceColor
            opacity: resultList.hoveredIndex >= 0
                && resultList.hoveredIndex !== resultList.currentIndex
                ? 1
                : 0

            Behavior on y {
                NumberAnimation {
                    duration: ShellMetrics.fastAnimationMs
                    easing.type: Easing.InOutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: ShellMetrics.fastAnimationMs
                    easing.type: Easing.InOutCubic
                }
            }
        }

        delegate: Item {
            required property var modelData
            required property int index

            readonly property var result: modelData

            function launch(): void {
                if (result.tmuxSession) {
                    root.launchTmuxSession(result.name);
                } else {
                    result.application.execute();
                    root.closeRequested();
                }
            }

            width: resultList.width
            height: root.resultRowHeight

            IconImage {
                id: resultIcon

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }
                implicitSize: 38
                visible: !parent.result.tmuxSession
                source: Quickshell.iconPath(
                    parent.result.tmuxSession
                        ? ""
                        : parent.result.application.icon,
                    "application-x-executable"
                )
                asynchronous: true
            }

            Text {
                anchors {
                    left: parent.result.tmuxSession
                        ? parent.left
                        : resultIcon.right
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                    rightMargin: 12
                }
                text: parent.result.name
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 15
                font.weight: Font.Normal
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            HoverHandler {
                id: resultHover

                cursorShape: Qt.PointingHandCursor
                onHoveredChanged: {
                    if (hovered) {
                        resultList.hoverHighlightY = index * root.resultRowHeight;
                        resultList.hoveredIndex = index;
                    } else {
                        const exitedIndex = index;
                        Qt.callLater(() => {
                            if (resultList.hoveredIndex === exitedIndex)
                                resultList.hoveredIndex = -1;
                        });
                    }
                }
            }

            TapHandler {
                onTapped: parent.launch()
            }
        }
    }

    Text {
        anchors.centerIn: resultList
        visible: resultList.count === 0
        text: root.tmuxMode ? "No tmux sessions found" : "No applications found"
        color: Theme.secondaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 14
    }

    onShownChanged: {
        if (shown) {
            const wasTmuxMode = root.tmuxMode;
            searchInput.text = root.initialQuery;
            if (root.tmuxMode && wasTmuxMode)
                root.refreshTmuxSessions();
            resultList.hoveredIndex = -1;
            resultList.currentIndex = resultList.count > 0 ? 0 : -1;
        }
    }

    onRequestSerialChanged: {
        if (shown)
            searchInput.text = root.initialQuery;
    }

    onTmuxModeChanged: {
        if (tmuxMode && shown)
            refreshTmuxSessions();
    }
}
