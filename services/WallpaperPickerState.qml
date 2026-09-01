pragma Singleton

import Quickshell

Singleton {
    property bool visible: false

    function show(): void {
        visible = true;
    }

    function hide(): void {
        visible = false;
    }

    function toggle(): void {
        visible = !visible;
    }
}
