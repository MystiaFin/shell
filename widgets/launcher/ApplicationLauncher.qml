import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import "../../components/common"
import "../../components/theme"

Item {
    id: root

    property bool shown: false
    property string initialQuery: ""
    property int requestSerial: 0
    property real maximumHeight: 620
    property real resultRowHeight: 60
    property real bottomPadding: ShellMetrics.panelContentInsetFromEdge
    property var tmuxSessions: []
    property var pendingTmuxSessions: []
    property int queryGeneration: 0

    readonly property bool tmuxMode: searchInput.text.startsWith("!")
    readonly property bool commandMode: searchInput.text.startsWith(">")
    readonly property real fixedContentHeight: 12 + 8 + 46 + bottomPadding
    readonly property int maximumVisibleRows: Math.max(1, Math.floor((maximumHeight - fixedContentHeight) / resultRowHeight))
    readonly property int visibleResultRows: Math.max(1, Math.min(filteredResults.values.length, maximumVisibleRows))
    readonly property real desiredHeight: Math.min(maximumHeight, fixedContentHeight + visibleResultRows * resultRowHeight)

    LauncherCommands {
        id: launcherCommands
    }

    property alias focusTarget: searchInput

    signal closeRequested

    function launchCurrentResult(): void {
        const index = resultList.currentIndex;
        if (index >= 0 && index < filteredResults.values.length)
            launchResult(filteredResults.values[index]);
    }

    function runCommand(command: string): void {
        console.log("Command selected:", command);
    }

    function launchResult(result): void {
        switch (result.type) {
        case "tmux":
            launchTmuxSession(result.name);
            break;
        case "command":
            runCommand(result.command);
            break;
        case "application":
            result.application.execute();
            root.closeRequested();
            break;
        }
    }

    function moveSelection(down: bool): void {
        if (resultList.count === 0)
            return;

        if (down)
            resultList.incrementCurrentIndex();
        else
            resultList.decrementCurrentIndex();

        resultList.positionViewAtIndex(resultList.currentIndex, ListView.Contain);
    }

    function refreshTmuxSessions(): void {
        if (tmuxSessionReader.running)
            return;

        pendingTmuxSessions = [];
        tmuxSessionReader.running = true;
    }

    function resetResults(): void {
        const generation = ++queryGeneration;
        Qt.callLater(() => {
            if (generation !== queryGeneration)
                return;

            resultList.forceLayout();
            resultList.currentIndex = resultList.count > 0 ? 0 : -1;
            resultList.positionViewAtBeginning();
        });
    }

    function launchTmuxSession(sessionName: string): void {
        const terminal = Quickshell.env("TERMINAL");
        if (!terminal || terminal.length === 0) {
            console.error("Cannot launch tmux session: TERMINAL is not set");
            return;
        }

        Quickshell.execDetached([terminal, "--", "tmux", "attach-session", "-t", sessionName]);
        root.closeRequested();
    }

    ScriptModel {
        id: filteredResults
        objectProp: "key"

        values: {
            if (root.commandMode) {
                const query = searchInput.text.slice(1).trim().toLowerCase();

                return launcherCommands.items.filter(command => query.length === 0 || command.name.toLowerCase().includes(query));
            }
            if (root.tmuxMode) {
                const query = searchInput.text.slice(1).trim().toLowerCase();
                const matches = query.length === 0 ? root.tmuxSessions : root.tmuxSessions.filter(sessionName => sessionName.toLowerCase().includes(query));

                return matches.map(sessionName => ({
                            key: "tmux:" + sessionName,
                            type: "tmux",
                            tmuxSession: true,
                            name: sessionName
                        }));
            }

            const query = searchInput.text.trim().toLowerCase();
            const applications = [...DesktopEntries.applications.values];
            const matches = query.length === 0 ? applications : applications.filter(application => {
                const searchable = [application.name, application.genericName, application.comment, ...application.keywords].join(" ").toLowerCase();

                return searchable.includes(query);
            });

            return matches.sort((first, second) => {
                const nameComparison = first.name.localeCompare(second.name);
                return nameComparison !== 0 ? nameComparison : first.id.localeCompare(second.id);
            }).map(application => ({
                        key: "app:" + application.id,
                        type: "application",
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

            onTextChanged: root.resetResults()
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
        reuseItems: false
        currentIndex: -1
        keyNavigationWraps: true
        highlightFollowsCurrentItem: false

        remove: Transition {
            MotionAnimation {
                type: MotionAnimation.FastEffects
                property: "opacity"
                from: 1
                to: 0
            }
        }

        highlight: Rectangle {
            width: resultList.width
            height: root.resultRowHeight
            y: resultList.currentItem ? resultList.currentItem.y : 0
            radius: ShellMetrics.radiusMedium
            color: Theme.selectedSurfaceColor
            opacity: resultList.currentItem ? 1 : 0

            Behavior on y {
                MotionAnimation {
                    type: MotionAnimation.FastSpatial
                }
            }
        }

        onCountChanged: {
            if (count === 0)
                currentIndex = -1;
            else if (currentIndex >= count)
                currentIndex = 0;
        }

        delegate: Item {
            id: resultDelegate

            required property var modelData
            required property int index

            readonly property var result: modelData

            width: resultList.width
            height: root.resultRowHeight

            Rectangle {
                anchors.fill: parent
                radius: ShellMetrics.radiusMedium
                color: Theme.hoverSurfaceColor
                opacity: resultHover.hovered && !resultDelegate.ListView.isCurrentItem ? 1 : 0

                Behavior on opacity {
                    MotionAnimation {
                        type: MotionAnimation.FastEffects
                    }
                }
            }

            IconImage {
                id: resultIcon

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }

                implicitSize: 38
                visible: parent.result.type === "application"
                source: parent.result.type === "application" ? Quickshell.iconPath(parent.result.application.icon, "application-x-executable") : ""
                asynchronous: true
            }

            Text {
                id: commandIcon

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }

                width: 38

                visible: parent.result.type === "command"
                text: parent.result.type === "command" ? parent.result.icon : ""

                color: Theme.primaryTextColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors {
                    left: parent.result.type === "application" ? resultIcon.right : parent.result.type === "command" ? commandIcon.right : parent.left
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
            }

            TapHandler {
                onTapped: {
                    resultList.currentIndex = resultDelegate.index;
                    root.launchResult(resultDelegate.result);
                }
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
            root.resetResults();
        }
    }

    onRequestSerialChanged: {
        if (shown) {
            searchInput.text = root.initialQuery;
            root.resetResults();
        }
    }

    onTmuxModeChanged: {
        if (tmuxMode && shown)
            refreshTmuxSessions();
    }
}
