pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../components/theme"
import "ThemeExportUtils.js" as ThemeExportUtils

Singleton {
    id: root

    readonly property string homeDirectory: Quickshell.env("HOME")
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME")
        || homeDirectory + "/.config"
    readonly property string quickCssPath: configHome + "/vesktop/settings/quickCss.css"
    readonly property url templatePath: Qt.resolvedUrl("vesktop-theme.css")
    readonly property string blockStart: "/* quickshell-theme:start */"
    readonly property string blockEnd: "/* quickshell-theme:end */"

    function renderTheme(): string {
        const replacements = {
            "@COLOR_SCHEME@": Theme.lightMode ? "light" : "dark",
            "@BACKGROUND@": ThemeExportUtils.colorToHex(Theme.shellBackgroundColor),
            "@SURFACE@": ThemeExportUtils.colorToHex(Theme.panelSurfaceColor),
            "@HOVER@": ThemeExportUtils.colorToHex(Theme.hoverSurfaceColor),
            "@SELECTED@": ThemeExportUtils.colorToHex(Theme.selectedSurfaceColor),
            "@BORDER@": ThemeExportUtils.colorToHex(Theme.surfaceBorderColor),
            "@TEXT@": ThemeExportUtils.colorToHex(Theme.primaryTextColor),
            "@SECONDARY@": ThemeExportUtils.colorToHex(Theme.secondaryTextColor),
            "@MUTED@": ThemeExportUtils.colorToHex(Theme.mutedTextColor),
            "@ACCENT@": ThemeExportUtils.colorToHex(Theme.accentColor),
            "@ACCENT_HOVER@": ThemeExportUtils.colorToHex(Theme.accentHoverColor),
            "@ON_ACCENT@": ThemeExportUtils.colorToHex(Theme.accentTextColor),
            "@ACCENT_RGB@": ThemeExportUtils.colorToRgb(Theme.accentColor),
            "@SUCCESS@": ThemeExportUtils.colorToHex(Theme.successColor),
            "@DANGER@": ThemeExportUtils.colorToHex(Theme.dangerColor)
        };
        return blockStart + "\n"
            + ThemeExportUtils.applyReplacements(templateFile.text(), replacements).trim()
            + "\n" + blockEnd + "\n";
    }

    function exportTheme(): void {
        let existing = quickCssFile.text();
        const start = existing.indexOf(blockStart);
        const end = existing.indexOf(blockEnd);
        if (start >= 0 && end >= start)
            existing = existing.slice(0, start) + existing.slice(end + blockEnd.length);
        existing = existing.trim();
        quickCssFile.setText((existing === "" ? "" : existing + "\n\n") + renderTheme());
    }

    FileView {
        id: templateFile
        path: root.templatePath
        blockLoading: true
        printErrors: true
    }

    FileView {
        id: quickCssFile
        path: root.quickCssPath
        blockLoading: true
        atomicWrites: false
        printErrors: true
    }
}
