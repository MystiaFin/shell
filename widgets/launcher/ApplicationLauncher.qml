import Quickshell
import QtQuick
import "../../components/theme"
import "../../components/state"
import "../../services"

Item {
    id: root

    property bool shown: false
    property string initialQuery: ""
    property int requestSerial: 0

    property real maximumHeight: 620
    property real resultRowHeight: 60
    property real bottomPadding: ShellMetrics.panelContentInsetFromEdge

    readonly property real fixedContentHeight: 12 + 8 + 46 + bottomPadding

    readonly property int maximumVisibleRows: Math.max(1, Math.min(
        SettingsService.launcherVisibleRows,
        Math.floor((maximumHeight - fixedContentHeight) / resultRowHeight)))

    readonly property int visibleResultRows: Math.max(1, Math.min(launcherResults.values.length, maximumVisibleRows))

    readonly property real desiredHeight: Math.min(maximumHeight, fixedContentHeight + visibleResultRows * resultRowHeight)

    readonly property bool tmuxMode: launcherResults.tmuxMode

    readonly property bool commandMode: launcherResults.commandMode

    property alias focusTarget: searchField.focusTarget

    signal closeRequested

    LauncherCommands {
        id: launcherCommands
    }

    TmuxSessions {
        id: tmux
    }

    LauncherResults {
        id: launcherResults

        query: searchField.text

        commands: launcherCommands.items

        tmuxSessions: tmux.sessions
    }

    function launchResult(result): void {
        switch (result.type) {
        case "application":
            launchApplication(result);
            break;
        case "tmux":
            launchTmux(result);
            break;
        case "command":
            runCommand(result.command);
            break;
        case "colorScheme":
            Theme.setTheme(result.themeId);
            if (SettingsService.launcherCloseOnLaunch)
                root.closeRequested();
            break;
        }
    }

    function launchApplication(result): void {
        result.application.execute();
        if (SettingsService.launcherCloseOnLaunch)
            root.closeRequested();
    }

    function launchTmux(result): void {
        if (!tmux.launchSession(result.name))
            return;

        if (SettingsService.launcherCloseOnLaunch)
            root.closeRequested();
    }

    function runCommand(command: string): void {
        switch (command) {
        case "settings":
            OverlayState.showSettings();
            break;
        case "colorScheme":
            searchField.text = ">color ";
            break;
        case "tmux":
            searchField.text = "!";
            break;
        case "wallpapers":
            OverlayState.showWallpaperPicker();
            break;
        }
    }

    LauncherSearchField {
        id: searchField

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right

            bottomMargin: root.bottomPadding

            leftMargin: 14
            rightMargin: 14
        }

        onMoveSelectionRequested: down => resultList.moveSelection(down)

        onAccepted: resultList.activateCurrent()

        onCloseRequested: root.closeRequested()

        onTextChanged: resultList.resetSelection()
    }

    LauncherResultList {
        id: resultList

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: searchField.top

            topMargin: 12
            leftMargin: 14
            rightMargin: 14
            bottomMargin: 8
        }

        model: launcherResults

        rowHeight: root.resultRowHeight

        emptyText: root.tmuxMode ? "No tmux sessions found" : root.commandMode ? "No commands found" : "No applications found"

        onActivated: result => root.launchResult(result)
    }

    onShownChanged: {
        if (!shown)
            return;

        if (!SettingsService.launcherRememberQuery || root.initialQuery !== "")
            searchField.text = root.initialQuery;

        if (root.tmuxMode)
            tmux.refresh();

        resultList.resetSelection();
    }

    onRequestSerialChanged: {
        if (!shown)
            return;

        if (!SettingsService.launcherRememberQuery || root.initialQuery !== "")
            searchField.text = root.initialQuery;

        resultList.resetSelection();
    }

    onTmuxModeChanged: {
        if (tmuxMode && shown)
            tmux.refresh();
    }
}
