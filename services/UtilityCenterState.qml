pragma Singleton

import Quickshell

Singleton {
    property bool visible: false
    property string page: "notifications"
    property bool passwordEntryActive: false
    property bool statusBarHovered: false

    function toggle(): void {
        visible = !visible;
        if (!visible)
            passwordEntryActive = false;
    }

    function showPage(nextPage): void {
        if (visible && page === nextPage) {
            hide();
            return;
        }
        page = nextPage;
        visible = true;
    }

    function hide(): void {
        visible = false;
        passwordEntryActive = false;
    }
}
