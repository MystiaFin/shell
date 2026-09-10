pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string controlCenter: "controlCenter"
    readonly property string utilityCenter: "utilityCenter"
    readonly property string launcher: "launcher"
    readonly property string wallpaperPicker: "wallpaperPicker"
    readonly property string powerMenu: "powerMenu"

    property string activeOverlay: ""
    property string utilityPage: "notifications"
    property string launcherInitialQuery: ""
    property int launcherRequestSerial: 0
    property bool statusBarHovered: false

    readonly property bool controlCenterVisible: activeOverlay === controlCenter
    readonly property bool utilityCenterVisible: activeOverlay === utilityCenter
    readonly property bool launcherVisible: activeOverlay === launcher
    readonly property bool wallpaperPickerVisible: activeOverlay === wallpaperPicker
    readonly property bool powerMenuVisible: activeOverlay === powerMenu

    function toggle(overlay: string): void {
        activeOverlay = activeOverlay === overlay ? "" : overlay;
    }

    function show(overlay: string): void {
        activeOverlay = overlay;
    }

    function hide(overlay: string): void {
        if (activeOverlay === overlay)
            activeOverlay = "";
    }

    function toggleControlCenter(): void {
        toggle(controlCenter);
    }

    function hideControlCenter(): void {
        hide(controlCenter);
    }

    function toggleUtilityCenter(): void {
        toggle(utilityCenter);
    }

    function hideUtilityCenter(): void {
        hide(utilityCenter);
    }

    function showUtilityPage(page: string): void {
        utilityPage = page;
        show(utilityCenter);
    }

    function toggleLauncher(): void {
        if (launcherVisible) {
            hideLauncher();
        } else {
            showLauncher();
        }
    }

    function showLauncher(): void {
        launcherInitialQuery = "";
        launcherRequestSerial++;
        show(launcher);
    }

    function showTmuxLauncher(): void {
        launcherInitialQuery = "!";
        launcherRequestSerial++;
        show(launcher);
    }

    function hideLauncher(): void {
        hide(launcher);
    }

    function showWallpaperPicker(): void {
        show(wallpaperPicker);
    }

    function hideWallpaperPicker(): void {
        hide(wallpaperPicker);
    }

    function togglePowerMenu(): void {
        toggle(powerMenu);
    }

    function hidePowerMenu(): void {
        hide(powerMenu);
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggleLauncher();
        }

        function show(): void {
            root.showLauncher();
        }

        function showTmux(): void {
            root.showTmuxLauncher();
        }

        function hide(): void {
            root.hideLauncher();
        }

        function setVisible(visible: bool): void {
            if (visible)
                root.showLauncher();
            else
                root.hideLauncher();
        }

        function getVisible(): bool {
            return root.launcherVisible;
        }
    }
}
