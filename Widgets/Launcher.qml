import Quickshell
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel 2.15

Scope {
    // --- SETUP ---
    property string user: Quickshell.env("USER")
    property string home: Quickshell.env("HOME")

    Process {
        id: runner
    }

    FolderListModel {
        id: srcSystem
        folder: "file:///run/current-system/sw/share/applications"
        nameFilters: ["*.desktop"]
        showDirs: false
        onCountChanged: rebuildList()
    }
    FolderListModel {
        id: srcUserModern
        folder: "file:///etc/profiles/per-user/" + user + "/share/applications"
        nameFilters: ["*.desktop"]
        showDirs: false
        onCountChanged: rebuildList()
    }
    FolderListModel {
        id: srcUserLegacy
        folder: "file://" + home + "/.nix-profile/share/applications"
        nameFilters: ["*.desktop"]
        showDirs: false
        onCountChanged: rebuildList()
    }
    FolderListModel {
        id: srcLocal
        folder: "file://" + home + "/.local/share/applications"
        nameFilters: ["*.desktop"]
        showDirs: false
        onCountChanged: rebuildList()
    }

    ListModel {
        id: displayModel
    }

    function rebuildList() {
        var query = input.text.toLowerCase();
        displayModel.clear();

        function addFrom(sourceModel) {
            for (var i = 0; i < sourceModel.count; i++) {
                var fileName = sourceModel.get(i, "fileName");

                var launchId = fileName.toString().replace(".desktop", "");

                var displayName = launchId;
                displayName = displayName.replace(/^org\.gnome\./, "").replace(/^com\.[a-z]+\./, "").replace(/^io\.[a-z]+\./, "");
                displayName = displayName.charAt(0).toUpperCase() + displayName.slice(1);

                // 3. Filter and Add
                if (displayName.toLowerCase().includes(query)) {
                    displayModel.append({
                        "displayName": displayName,
                        "launchId": launchId
                    });
                }
            }
        }

        addFrom(srcUserModern);
        addFrom(srcSystem);
        addFrom(srcUserLegacy);
        addFrom(srcLocal);

        appList.currentIndex = 0;
    }

    function launchCurrent() {
        var item = displayModel.get(appList.currentIndex);
        if (item) {
            runner.command = ["gtk-launch", item.launchId];
            runner.running = true;
            root.visible = false;
        }
    }

    PanelWindow {
        id: root
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        color: "transparent"
        focusable: true
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            id: container
            width: 500
            height: col.height + 30

            anchors.centerIn: parent
            color: "#1e1e2e"
            radius: 8

            MouseArea {
                anchors.fill: parent
            }

            Column {
                id: col
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 15
                spacing: 10

                ListView {
                    id: appList
                    width: parent.width

                    property int calculatedHeight: displayModel.count * 40
                    height: Math.min(calculatedHeight, 320)

                    Behavior on height {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutQuad
                        }
                    }
                    visible: displayModel.count > 0

                    clip: true
                    model: displayModel

                    highlight: Rectangle {
                        color: "#313244"
                        radius: 4
                    }
                    highlightMoveDuration: 0

                    delegate: Item {
                        width: appList.width
                        height: 40

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: appList.currentIndex = index
                            onClicked: launchCurrent()
                        }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            spacing: 10

                            Image {
                                id: iconImg
                                source: "image://icon/" + model.launchId
                                width: 24
                                height: 24
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                                onStatusChanged: if (iconImg.status === Image.Error)
                                    iconImg.source = "image://icon/application-x-executable"
                            }

                            Text {
                                text: model.displayName
                                color: ListView.isCurrentItem ? "#a6e3a1" : "#cdd6f4"
                                font.bold: ListView.isCurrentItem
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // SEARCH BAR
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "#181825"
                    radius: 4

                    TextInput {
                        id: input
                        anchors.fill: parent
                        anchors.margins: 12
                        color: "white"
                        font.pixelSize: 18
                        verticalAlignment: Text.AlignVCenter
                        focus: true
                        Component.onCompleted: forceActiveFocus()

                        onTextChanged: rebuildList()

                        Keys.onDownPressed: appList.incrementCurrentIndex()
                        Keys.onUpPressed: appList.decrementCurrentIndex()
                        Keys.onReturnPressed: launchCurrent()
                        Keys.onEscapePressed: root.visible = false
                    }
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: root.visible = false
        }
    }
}
