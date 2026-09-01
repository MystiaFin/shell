pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool launcherVisible: false

    function toggle(): void {
        launcherVisible = true;
    }

    function show(): void {
        launcherVisible = true;
    }

    function hide(): void {
        launcherVisible = false;
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggle();
        }

        function show(): void {
            root.show();
        }

        function hide(): void {
            root.hide();
        }

        function setVisible(visible: bool): void {
            root.launcherVisible = visible;
        }

        function getVisible(): bool {
            return root.launcherVisible;
        }
    }
}
