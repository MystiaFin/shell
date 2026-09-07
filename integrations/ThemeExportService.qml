pragma Singleton

import Quickshell
import QtQuick
import "../components/theme"

Singleton {
    id: root

    property bool active: false

    function activateExternalThemeIntegration(): void {
        if (active)
            return;
        active = true;
        GtkThemeService.prepareThemeDirectories();
        ApplicationThemeService.prepareThemeDirectory();
        scheduleThemeExport();
    }

    function scheduleThemeExport(): void {
        if (active)
            exportTimer.restart();
    }

    function exportExternalTheme(): void {
        TerminalThemeService.exportTerminalTheme();
        GtkThemeService.exportGtkTheme();
        ApplicationThemeService.exportApplicationThemes();
    }

    Timer {
        id: exportTimer
        interval: 300
        onTriggered: root.exportExternalTheme()
    }

    Connections {
        target: Theme

        function onShellBackgroundColorChanged(): void { root.scheduleThemeExport(); }
        function onPanelSurfaceColorChanged(): void { root.scheduleThemeExport(); }
        function onSurfaceBorderColorChanged(): void { root.scheduleThemeExport(); }
        function onSelectedSurfaceColorChanged(): void { root.scheduleThemeExport(); }
        function onPrimaryTextColorChanged(): void { root.scheduleThemeExport(); }
        function onSecondaryTextColorChanged(): void { root.scheduleThemeExport(); }
        function onMutedTextColorChanged(): void { root.scheduleThemeExport(); }
        function onAccentColorChanged(): void { root.scheduleThemeExport(); }
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
        target: ApplicationThemeService
        function onPreparationCompleted(): void { root.scheduleThemeExport(); }
    }
}
