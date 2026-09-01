pragma Singleton

import Quickshell

Singleton {
    property bool visible: false
    property bool statusBarHovered: false

    function toggle(): void {
        visible = !visible;
    }

    function hide(): void {
        visible = false;
    }
}
