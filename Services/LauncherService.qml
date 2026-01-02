pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    property bool launcherVisible: false
    property var applications: DesktopEntries.applications
    property int selectedIndex: 0
    property var selectedApp: null
    property string searchText: ""

    property Process launcher: Process {}
    
    function launchSelected() {
        if (!selectedApp || !selectedApp.id) {
            console.log("ERROR: No app selected or app has no id");
            return;
        }

        console.log("Launching:", selectedApp.id);
        launcher.command = ["gtk-launch", selectedApp.id];
        launcher.running = false;
        launcher.running = true;

    }

    function closeLauncher() {
        launcherVisible = false;
        searchText = ""
    }
}
