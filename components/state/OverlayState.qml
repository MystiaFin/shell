pragma Singleton

import Quickshell
import Quickshell.Io
import "../../services"

Singleton {
    id: root

    readonly property string controlCenter: "controlCenter"
    readonly property string utilityCenter: "utilityCenter"
    readonly property string launcher: "launcher"
    readonly property string wallpaperPicker: "wallpaperPicker"
    readonly property string powerMenu: "powerMenu"
    readonly property string settings: "settings"

    property string activeOverlay: ""
    property string utilityPage: "notifications"
    property string launcherInitialQuery: ""
    property int launcherRequestSerial: 0
    property string wallpaperOutputName: ""
    property int wallpaperRequestSerial: 0
    property string settingsOutputName: ""
    property int settingsRequestSerial: 0
    property bool statusBarHovered: false

    readonly property bool controlCenterVisible: activeOverlay === controlCenter
    readonly property bool utilityCenterVisible: activeOverlay === utilityCenter
    readonly property bool launcherVisible: activeOverlay === launcher
    readonly property bool wallpaperPickerVisible: activeOverlay === wallpaperPicker
    readonly property bool powerMenuVisible: activeOverlay === powerMenu
    readonly property bool settingsVisible: activeOverlay === settings

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

    function focusedOutputName(): string {
        const workspace = NiriService.workspaces.find(item => item.is_focused);
        return workspace && workspace.output ? workspace.output : "";
    }

    function showWallpaperPicker(): void {
        wallpaperOutputName = focusedOutputName();
        wallpaperRequestSerial++;
        show(wallpaperPicker);
    }

    function hideWallpaperPicker(): void {
        hide(wallpaperPicker);
    }

    function showSettings(): void {
        settingsOutputName = focusedOutputName();
        settingsRequestSerial++;
        show(settings);
    }

    function hideSettings(): void {
        hide(settings);
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

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            if (root.wallpaperPickerVisible)
                root.hideWallpaperPicker();
            else
                root.showWallpaperPicker();
        }

        function show(): void {
            root.showWallpaperPicker();
        }

        function hide(): void {
            root.hideWallpaperPicker();
        }

        function setVisible(visible: bool): void {
            if (visible)
                root.showWallpaperPicker();
            else
                root.hideWallpaperPicker();
        }

        function getVisible(): bool {
            return root.wallpaperPickerVisible;
        }
    }
}
