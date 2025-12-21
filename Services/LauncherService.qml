import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel 2.15

Item {
    id: service

    // Logic Inputs
    property string user: Quickshell.env("USER")
    property string home: Quickshell.env("HOME")
    property string searchText: ""

    // Logic Outputs
    property alias displayModel: displayModel

    // Triggers
    onSearchTextChanged: rebuildList()

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
        var query = searchText.toLowerCase();
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
    }

    function launch(launchId) {
        runner.command = ["gtk-launch", launchId];
        runner.running = true;
    }
}
