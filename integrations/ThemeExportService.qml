pragma Singleton

import Quickshell
import QtQuick
import "../components/theme"
import "../services"

Singleton {
    id: root

    property bool initialized: false

    function initialize(): void {
        if (initialized)
            return;
        initialized = true;
        prepareEnabledIntegrations();
        scheduleThemeExport();
    }

    function prepareEnabledIntegrations(): void {
        if (SettingsService.gtkIntegration)
            GtkThemeService.prepareThemeDirectories();
        if (SettingsService.spotifyIntegration)
            SpotifyThemeService.prepareThemeDirectory();
        if (SettingsService.btopIntegration)
            BtopThemeService.prepareThemeDirectory();
        if (SettingsService.cavaIntegration)
            CavaThemeService.prepareThemeDirectory();
    }

    function integrationEnabled(name: string): bool {
        return SettingsService.integrationEnabled(name);
    }

    function integrationChanged(name: string, enabled: bool): void {
        if (!initialized || !enabled)
            return;
        if (name === "gtk")
            GtkThemeService.prepareThemeDirectories();
        else if (name === "spotify")
            SpotifyThemeService.prepareThemeDirectory();
        else if (name === "btop")
            BtopThemeService.prepareThemeDirectory();
        else if (name === "cava")
            CavaThemeService.prepareThemeDirectory();
        scheduleThemeExport();
    }

    function scheduleThemeExport(): void {
        if (initialized)
            exportTimer.restart();
    }

    function exportExternalTheme(): void {
        if (integrationEnabled("terminal")) TerminalThemeService.exportTerminalTheme();
        if (integrationEnabled("gtk")) GtkThemeService.exportGtkTheme();
        if (integrationEnabled("spotify")) SpotifyThemeService.exportTheme();
        if (integrationEnabled("vesktop")) VesktopThemeService.exportTheme();
        if (integrationEnabled("btop")) BtopThemeService.exportTheme();
        if (integrationEnabled("cava")) CavaThemeService.exportTheme();
        if (integrationEnabled("tmux")) TmuxThemeService.exportTheme();
    }

    Timer {
        id: exportTimer
        interval: 300
        onTriggered: root.exportExternalTheme()
    }

    Connections {
        target: SettingsService

        function onTerminalIntegrationChanged(): void { root.integrationChanged("terminal", SettingsService.terminalIntegration); }
        function onGtkIntegrationChanged(): void { root.integrationChanged("gtk", SettingsService.gtkIntegration); }
        function onSpotifyIntegrationChanged(): void { root.integrationChanged("spotify", SettingsService.spotifyIntegration); }
        function onVesktopIntegrationChanged(): void { root.integrationChanged("vesktop", SettingsService.vesktopIntegration); }
        function onBtopIntegrationChanged(): void { root.integrationChanged("btop", SettingsService.btopIntegration); }
        function onCavaIntegrationChanged(): void { root.integrationChanged("cava", SettingsService.cavaIntegration); }
        function onTmuxIntegrationChanged(): void { root.integrationChanged("tmux", SettingsService.tmuxIntegration); }
    }

    Connections {
        target: Theme

        function onShellBackgroundColorChanged(): void { root.scheduleThemeExport(); }
        function onPanelSurfaceColorChanged(): void { root.scheduleThemeExport(); }
        function onHoverSurfaceColorChanged(): void { root.scheduleThemeExport(); }
        function onSurfaceBorderColorChanged(): void { root.scheduleThemeExport(); }
        function onSelectedSurfaceColorChanged(): void { root.scheduleThemeExport(); }
        function onPrimaryTextColorChanged(): void { root.scheduleThemeExport(); }
        function onSecondaryTextColorChanged(): void { root.scheduleThemeExport(); }
        function onMutedTextColorChanged(): void { root.scheduleThemeExport(); }
        function onAccentColorChanged(): void { root.scheduleThemeExport(); }
        function onAccentHoverColorChanged(): void { root.scheduleThemeExport(); }
        function onAccentTextColorChanged(): void { root.scheduleThemeExport(); }
        function onLightModeChanged(): void { root.scheduleThemeExport(); }
        function onSuccessColorChanged(): void { root.scheduleThemeExport(); }
        function onDangerColorChanged(): void { root.scheduleThemeExport(); }
    }

    Connections {
        target: GtkThemeService
        function onPreparationCompleted(): void { root.scheduleThemeExport(); }
    }

    Connections {
        target: SpotifyThemeService
        function onPreparationCompleted(): void { root.scheduleThemeExport(); }
    }

    Connections {
        target: BtopThemeService
        function onPreparationCompleted(): void { root.scheduleThemeExport(); }
    }

    Connections {
        target: CavaThemeService
        function onPreparationCompleted(): void { root.scheduleThemeExport(); }
    }
}
