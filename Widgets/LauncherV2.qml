import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Services"
import "../Components"

PanelWindow {
    id: root
    signal requestClose

    property bool closing: false

    visible: LauncherService.launcherVisible
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    anchors.bottom: true
    width: 420
    height: 500
    color: "transparent"

    margins {
        bottom: (visible && !closing) ? 0 : -499
        Behavior on bottom {
            NumberAnimation {
                id: slideAnim
                duration: 300
                easing.type: Easing.OutQuad
                onRunningChanged: {
                    if (!running && root.closing) {
                        root.requestClose();
                        root.closing = false;
                    }
                }
            }
        }
    }

    function startClose() {
        closing = true;
    }

    FocusScope {
        id: mainFocus
        anchors.fill: parent
        focus: true

        Keys.onUpPressed: entriesList.selectPrevious()
        Keys.onDownPressed: entriesList.selectNext()
        Keys.onReturnPressed: {
            LauncherService.launchSelected();
            root.startClose();
        }
        Keys.onEscapePressed: root.startClose()

        Rectangle {
            id: background
            anchors.left: contentColumn.left
            anchors.right: contentColumn.right
            anchors.top: contentColumn.top
            anchors.bottom: contentColumn.bottom
            anchors.margins: -10

            color: "#181825"
            radius: 10
            border.width: 2
            border.color: "#313244"
        }
        Column {
            id: contentColumn
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10

            spacing: 10
            clip: true

            DesktopEntriesComponent {
                id: entriesList
                width: parent.width
                height: Math.min(contentHeight, 420)
                Behavior on height {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }
            }

            LauncherSearch {
                id: searchBar
                focus: true
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            closing = false;
            LauncherService.selectedIndex = 0;
            LauncherService.searchText = "";
            searchBar.text = "";
            Qt.callLater(function () {
                searchBar.forceActiveFocus();
            });
        }
    }
}
