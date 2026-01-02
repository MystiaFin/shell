import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Services"
import "../Components"

PanelWindow {
    id: root
    signal requestClose

    visible: LauncherService.launcherVisible
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors.bottom: true
    anchors.left: true
    width: 500
    height: 500
    color: "transparent"

    margins {
        bottom: visible ? 0 : -499
        Behavior on bottom {
            NumberAnimation {
                duration: 300
            }
        }
    }

    FocusScope {
        id: mainFocus
        anchors.fill: parent
        focus: true

        Keys.onUpPressed: {
            entriesList.selectPrevious();
        }

        Keys.onDownPressed: {
            entriesList.selectNext();
        }

        Keys.onReturnPressed: {
            LauncherService.launchSelected();
            root.requestClose();
        }

        Keys.onEscapePressed: {
            root.requestClose();
        }

        Rectangle {
            anchors.fill: parent
            color: "#1e1e1e"
            radius: 10
            clip: true

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                DesktopEntriesComponent {
                    id: entriesList
                    width: parent.width
                    height: parent.height - 60
                }

                LauncherSearch {
                    id: searchBar
                    focus: true
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            LauncherService.selectedIndex = 0;
            LauncherService.searchText = "";
            searchBar.text = "";
            Qt.callLater(function () {
                searchBar.forceActiveFocus();
            });
        }
    }
}
