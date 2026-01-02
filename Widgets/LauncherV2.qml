import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../Anim"

PanelWindow {
    id: launcher

    signal requestClose

    property bool visible: false
    property int itemHeight: 42
    property int maxItems: 9
    property int searchHeight: 50
    property int spacing: 10
    property int padding: 10
    property int extraHeight: 10
    property int totalMaxHeight: (maxItems * itemHeight) + searchHeight + spacing + (padding * 2) + extraHeight
    property string searchText: ""
    property int highlightedIndex: 0

    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors.bottom: true
    margins {
        bottom: visible ? 0 : -(totalMaxHeight - 1)
        Behavior on bottom {
            LauncherAnim {
                duration: 400
            }
        }
    }

    implicitWidth: 500
    implicitHeight: totalMaxHeight
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    Process {
        id: appLauncher
        running: false
    }

    function launchApp(desktopId) {
        if (desktopId) {
            appLauncher.command = ["sh", "-c", "gtk-launch " + desktopId];
            appLauncher.running = true;
            launcher.requestClose();
        }
    }

    function getVisibleCount() {
        var count = 0;
        for (var i = 0; i < DesktopEntries.applications.length; i++) {
            var app = DesktopEntries.applications[i];
            if (launcher.searchText === "") {
                count++;
            } else {
                var name = (app.name || "").toLowerCase();
                var description = (app.description || "").toLowerCase();
                if (name.indexOf(launcher.searchText) !== -1 || description.indexOf(launcher.searchText) !== -1) {
                    count++;
                }
            }
        }
        return count;
    }

    // Background rectangle
    Rectangle {
        id: background
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: {
            var listHeight = appColumn.height;
            var extras = launcher.searchHeight + launcher.spacing + (launcher.padding * 2);
            var total = listHeight + extras;
            return Math.min(total, parent.height);
        }

        color: root.systemColor
        radius: 16

        Behavior on height {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutExpo
            }
        }
    }

    // Desktop entries container (transparent)
    Item {
        id: entriesContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: searchBar.top
        anchors.top: parent.top
        anchors.margins: launcher.padding
        anchors.bottomMargin: launcher.spacing
        clip: true

        Column {
            id: appColumn
            width: parent.width
            spacing: 5
            anchors.bottom: parent.bottom

            Repeater {
                model: DesktopEntries.applications

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    property int visibleIndex: {
                        var count = 0;
                        for (var i = 0; i < index; i++) {
                            var app = DesktopEntries.applications[i];
                            if (launcher.searchText === "") {
                                count++;
                            } else {
                                var n = (app.name || "").toLowerCase();
                                var d = (app.description || "").toLowerCase();
                                if (n.indexOf(launcher.searchText) !== -1 || d.indexOf(launcher.searchText) !== -1) {
                                    count++;
                                }
                            }
                        }
                        return count;
                    }

                    property bool shouldBeVisible: {
                        if (launcher.searchText === "")
                            return true;
                        var name = (modelData.name || "").toLowerCase();
                        var description = (modelData.description || "").toLowerCase();
                        return name.indexOf(launcher.searchText) !== -1 || description.indexOf(launcher.searchText) !== -1;
                    }

                    visible: height > 0
                    property bool isHighlighted: shouldBeVisible && visibleIndex === launcher.highlightedIndex

                    width: parent.width
                    height: shouldBeVisible ? launcher.itemHeight : 0
                    opacity: shouldBeVisible ? 1 : 0
                    color: isHighlighted ? "#3a3a3a" : (mouseArea.containsMouse ? "#2a2a2a" : "transparent")
                    radius: 6

                    Behavior on height {
                        NumberAnimation {
                            duration: 350
                            easing.type: Easing.OutExpo
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 350
                            easing.type: Easing.OutExpo
                        }
                    }

                    Row {
                        spacing: 10
                        anchors.fill: parent
                        anchors.leftMargin: 10

                        Image {
                            width: 32
                            height: 32
                            source: (modelData.icon ? "image://icon/" + modelData.icon : "")
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 52

                            Text {
                                text: modelData.name || ""
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            Text {
                                text: modelData.description || ""
                                color: "#b0b0b0"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: parent.shouldBeVisible

                        onClicked: launcher.launchApp(modelData.id)
                        onEntered: launcher.highlightedIndex = visibleIndex
                    }
                }
            }
        }
    }

    // Search bar
    Rectangle {
        id: searchBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: launcher.padding
        height: launcher.searchHeight
        color: "#2a2a2a"
        radius: 8
        border.color: "#4a9eff"
        border.width: 2

        Row {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Text {
                text: "🔍"
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
            }

            TextInput {
                id: searchInput
                width: parent.width - 60
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                font.pixelSize: 16
                selectByMouse: true
                clip: true
                focus: true

                Text {
                    text: "Search applications..."
                    color: "#808080"
                    font.pixelSize: 16
                    visible: searchInput.text.length === 0
                }

                onTextChanged: {
                    launcher.searchText = text.toLowerCase();
                    var count = launcher.getVisibleCount();
                    launcher.highlightedIndex = count > 0 ? count - 1 : 0;
                }

                Keys.onEscapePressed: {
                    if (text.length > 0)
                        text = "";
                    else
                        launcher.requestClose();
                }

                Keys.onUpPressed: {
                    if (launcher.highlightedIndex > 0) {
                        launcher.highlightedIndex--;
                    }
                }

                Keys.onDownPressed: {
                    var count = launcher.getVisibleCount();
                    if (launcher.highlightedIndex < count - 1) {
                        launcher.highlightedIndex++;
                    }
                }

                Keys.onReturnPressed: {
                    var currentVisibleIndex = 0;

                    for (var i = 0; i < DesktopEntries.applications.length; i++) {
                        var app = DesktopEntries.applications[i];

                        var name = (app.name || "").toLowerCase();
                        var desc = (app.description || "").toLowerCase();
                        var isMatch = launcher.searchText === "" || name.indexOf(launcher.searchText) !== -1 || desc.indexOf(launcher.searchText) !== -1;

                        if (isMatch) {
                            if (currentVisibleIndex === launcher.highlightedIndex) {
                                launcher.launchApp(app.id);
                                break;
                            }
                            currentVisibleIndex++;
                        }
                    }
                }

                Component.onCompleted: forceActiveFocus()
            }

            Rectangle {
                width: 24
                height: 24
                radius: 12
                color: clearMouseArea.containsMouse ? "#4a4a4a" : "transparent"
                visible: searchInput.text.length > 0
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: "✕"
                    color: "white"
                    anchors.centerIn: parent
                    font.pixelSize: 14
                }

                MouseArea {
                    id: clearMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        searchInput.text = "";
                        searchInput.forceActiveFocus();
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            searchInput.text = "";
            highlightedIndex = 0;
            searchInput.forceActiveFocus();
        }
    }
}
