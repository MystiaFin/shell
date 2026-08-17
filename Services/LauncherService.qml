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
        launcher.command = ["sh", "-c", "gtk-launch " + selectedApp.id + " > /dev/null 2>&1"];
        launcher.running = false;
        launcher.running = true;
    }

    function closeLauncher() {
        launcherVisible = false;
        searchText = "";
    }
}
