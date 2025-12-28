import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel 2.15

Item {
    id: service

    property alias appModel: appModel
    property alias runner: runner

    property string currentQuery: ""

    Process { id: runner }

    FolderListModel {
        id: srcSystem
        folder: "file:///run/current-system/sw/share/applications"
        nameFilters: ["*.desktop"]; showDirs: false
        // When apps load, rebuild using the last known query
        onCountChanged: service.rebuildList(service.currentQuery)
    }

    FolderListModel {
        id: srcUser
        folder: "file:///etc/profiles/per-user/" + Quickshell.env("USER") + "/share/applications"
        nameFilters: ["*.desktop"]; showDirs: false
        onCountChanged: service.rebuildList(service.currentQuery)
    }

    ListModel { id: appModel }

    function rebuildList(text) {
        currentQuery = text.toLowerCase();
        appModel.clear();

        function add(src) {
            for (var i = 0; i < src.count; i++) {
                var name = src.get(i, "fileName").replace(".desktop", "");
                var display = name.replace(/^org\.gnome\./, "").replace(/^com\.[a-z]+\./, "");
                display = display.charAt(0).toUpperCase() + display.slice(1);
                
                if (display.toLowerCase().includes(currentQuery)) {
                    appModel.append({ "name": display, "id": name });
                }
            }
        }
        add(srcUser); 
        add(srcSystem);
    }
}
