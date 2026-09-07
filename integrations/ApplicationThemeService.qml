pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../components/theme"

Singleton {
    id: root

    readonly property string homeDirectory: Quickshell.env("HOME")
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME")
        || homeDirectory + "/.config"
    readonly property string cacheHome: Quickshell.env("XDG_CACHE_HOME")
        || homeDirectory + "/.cache"
    readonly property string themeDirectory: cacheHome + "/quickshell-theme"
    readonly property string spotifyThemePath: themeDirectory + "/spotify.css"
    readonly property string btopThemePath: configHome + "/btop/themes/quickshell.theme"
    readonly property string cavaThemePath: configHome + "/cava/themes/quickshell"
    readonly property string vesktopQuickCssPath: configHome
        + "/vesktop/settings/quickCss.css"
    readonly property string vesktopBlockStart: "/* quickshell-theme:start */"
    readonly property string vesktopBlockEnd: "/* quickshell-theme:end */"
    property bool directoryPrepared: false
    signal preparationCompleted()

    function colorToHex(colorValue: color): string {
        const channel = value => Math.round(value * 255).toString(16).padStart(2, "0");
        return "#" + channel(colorValue.r) + channel(colorValue.g)
            + channel(colorValue.b);
    }

    function colorToRgb(colorValue: color): string {
        return Math.round(colorValue.r * 255) + ", "
            + Math.round(colorValue.g * 255) + ", "
            + Math.round(colorValue.b * 255);
    }

    function renderVesktopCss(): string {
        const background = colorToHex(Theme.shellBackgroundColor);
        const surface = colorToHex(Theme.panelSurfaceColor);
        const selected = colorToHex(Theme.selectedSurfaceColor);
        const border = colorToHex(Theme.surfaceBorderColor);
        const text = colorToHex(Theme.primaryTextColor);
        const secondary = colorToHex(Theme.secondaryTextColor);
        const muted = colorToHex(Theme.mutedTextColor);
        const accent = colorToHex(Theme.accentColor);
        const accentHover = colorToHex(Theme.accentHoverColor);
        const accentText = colorToHex(Theme.accentTextColor);
        const success = colorToHex(Theme.successColor);
        const danger = colorToHex(Theme.dangerColor);

        return vesktopBlockStart + "\n"
            + ":root:root, .theme-dark.theme-dark, .theme-light.theme-light {\n"
            + "  color-scheme: " + (Theme.lightMode ? "light" : "dark") + ";\n"
            + "  --background-primary: " + background + ";\n"
            + "  --background-secondary: " + surface + ";\n"
            + "  --background-secondary-alt: " + background + ";\n"
            + "  --background-tertiary: " + background + ";\n"
            + "  --background-floating: " + surface + ";\n"
            + "  --background-base-lowest: " + background + ";\n"
            + "  --background-base-lower: " + background + ";\n"
            + "  --background-base-low: " + surface + ";\n"
            + "  --background-surface-high: " + selected + ";\n"
            + "  --background-surface-higher: " + border + ";\n"
            + "  --bg-base-primary: " + background + ";\n"
            + "  --bg-base-secondary: " + surface + ";\n"
            + "  --bg-base-tertiary: " + selected + ";\n"
            + "  --modal-background: " + background + ";\n"
            + "  --modal-footer-background: " + surface + ";\n"
            + "  --channeltextarea-background: " + surface + ";\n"
            + "  --input-background: " + surface + ";\n"
            + "  --chat-background-default: " + surface + ";\n"
            + "  --chat-text-muted: " + muted + ";\n"
            + "  --card-primary-bg: " + surface + ";\n"
            + "  --card-secondary-bg: " + selected + ";\n"
            + "  --background-modifier-hover: " + selected + ";\n"
            + "  --background-modifier-active: " + border + ";\n"
            + "  --background-modifier-selected: " + selected + ";\n"
            + "  --background-modifier-accent: " + border + ";\n"
            + "  --background-mod-subtle: " + selected + ";\n"
            + "  --background-mod-normal: " + selected + ";\n"
            + "  --background-mod-strong: " + border + ";\n"
            + "  --background-mod-muted: " + surface + ";\n"
            + "  --background-message-hover: " + selected + ";\n"
            + "  --message-background-hover: " + selected + ";\n"
            + "  --message-reacted-background: " + selected + ";\n"
            + "  --message-reacted-text: " + accent + ";\n"
            + "  --card-background-default: " + surface + ";\n"
            + "  --input-background-default: " + surface + ";\n"
            + "  --input-border-default: " + border + ";\n"
            + "  --border-subtle: " + border + ";\n"
            + "  --border-muted: " + border + ";\n"
            + "  --border-normal: " + border + ";\n"
            + "  --border-strong: " + accent + ";\n"
            + "  --border-focus: " + accent + ";\n"
            + "  --text-normal: " + text + ";\n"
            + "  --text-default: " + text + ";\n"
            + "  --text-primary: " + text + ";\n"
            + "  --text-strong: " + text + ";\n"
            + "  --text-brand: " + accent + ";\n"
            + "  --header-primary: " + text + ";\n"
            + "  --header-secondary: " + secondary + ";\n"
            + "  --text-muted: " + muted + ";\n"
            + "  --text-subtle: " + muted + ";\n"
            + "  --text-subdued: " + secondary + ";\n"
            + "  --text-base: " + text + ";\n"
            + "  --text-link: " + accent + ";\n"
            + "  --text-bright-accent: " + accent + ";\n"
            + "  --text-feedback-critical: " + danger + ";\n"
            + "  --text-secondary: " + secondary + ";\n"
            + "  --interactive-normal: " + secondary + ";\n"
            + "  --interactive-hover: " + text + ";\n"
            + "  --interactive-active: " + text + ";\n"
            + "  --interactive-muted: " + muted + ";\n"
            + "  --channels-default: " + secondary + ";\n"
            + "  --brand-500: " + accent + ";\n"
            + "  --brand-560: " + accentHover + ";\n"
            + "  --brand-600: " + accentHover + ";\n"
            + "  --brand-500-rgb: " + colorToRgb(Theme.accentColor) + ";\n"
            + "  --control-brand-foreground: " + accent + ";\n"
            + "  --control-brand-foreground-new: " + accent + ";\n"
            + "  --control-primary-background-default: " + accent + ";\n"
            + "  --control-primary-background-hover: " + accentHover + ";\n"
            + "  --control-primary-border-default: " + accent + ";\n"
            + "  --control-primary-border-hover: " + accentHover + ";\n"
            + "  --control-primary-text-default: " + accentText + ";\n"
            + "  --control-primary-text-hover: " + accentText + ";\n"
            + "  --control-secondary-background-default: " + surface + ";\n"
            + "  --control-secondary-background-hover: " + selected + ";\n"
            + "  --control-secondary-border-default: " + border + ";\n"
            + "  --control-secondary-border-hover: " + accent + ";\n"
            + "  --control-secondary-text-default: " + text + ";\n"
            + "  --control-secondary-text-hover: " + text + ";\n"
            + "  --control-icon-only-background-hover: " + selected + ";\n"
            + "  --control-icon-only-background-active: " + border + ";\n"
            + "  --control-icon-only-border-hover: " + border + ";\n"
            + "  --control-icon-only-border-active: " + accent + ";\n"
            + "  --control-icon-only-icon-default: " + secondary + ";\n"
            + "  --control-icon-only-icon-hover: " + text + ";\n"
            + "  --control-connected-background-default: " + success + ";\n"
            + "  --control-connected-background-hover: " + success + ";\n"
            + "  --control-critical-primary-background-default: " + danger + ";\n"
            + "  --control-critical-primary-background-hover: " + danger + ";\n"
            + "  --control-critical-primary-border-default: " + danger + ";\n"
            + "  --control-critical-primary-border-hover: " + danger + ";\n"
            + "  --control-critical-primary-text-default: " + accentText + ";\n"
            + "  --control-critical-primary-text-hover: " + accentText + ";\n"
            + "  --control-critical-secondary-background-default: " + surface + ";\n"
            + "  --control-critical-secondary-background-hover: " + selected + ";\n"
            + "  --control-critical-secondary-border-default: " + danger + ";\n"
            + "  --control-critical-secondary-border-hover: " + danger + ";\n"
            + "  --control-critical-secondary-text-default: " + danger + ";\n"
            + "  --control-critical-secondary-text-hover: " + danger + ";\n"
            + "  --background-feedback-critical: " + danger + ";\n"
            + "  --background-feedback-positive: " + success + ";\n"
            + "  --background-feedback-info: " + accent + ";\n"
            + "  --background-feedback-warning: " + accentHover + ";\n"
            + "  --icon-feedback-critical: " + danger + ";\n"
            + "  --icon-feedback-positive: " + success + ";\n"
            + "  --icon-feedback-info: " + accent + ";\n"
            + "  --icon-feedback-warning: " + accentHover + ";\n"
            + "  --icon-muted: " + muted + ";\n"
            + "  --profile-gradient-primary-color: " + surface + ";\n"
            + "  --profile-gradient-secondary-color: " + selected + ";\n"
            + "  --profile-gradient-overlay-color: " + background + ";\n"
            + "  --profile-gradient-modal-background-color: " + background + ";\n"
            + "  --profile-gradient-button-color: " + selected + ";\n"
            + "  --user-profile-background-hover: " + selected + ";\n"
            + "  --user-profile-border: " + border + ";\n"
            + "  --status-positive: " + success + ";\n"
            + "  --status-danger: " + danger + ";\n"
            + "}\n"
            + "[class*=channelTextArea] [class*=scrollableContainer],\n"
            + "[class*=channelTextArea] [class*=themedBackground] {\n"
            + "  background: " + surface + " !important;\n"
            + "}\n"
            + vesktopBlockEnd + "\n";
    }

    function renderSpotifyCss(): string {
        const background = colorToHex(Theme.shellBackgroundColor);
        const surface = colorToHex(Theme.panelSurfaceColor);
        const selected = colorToHex(Theme.selectedSurfaceColor);
        const border = colorToHex(Theme.surfaceBorderColor);
        const text = colorToHex(Theme.primaryTextColor);
        const secondary = colorToHex(Theme.secondaryTextColor);
        const muted = colorToHex(Theme.mutedTextColor);
        const accent = colorToHex(Theme.accentColor);
        const accentHover = colorToHex(Theme.accentHoverColor);
        const accentText = colorToHex(Theme.accentTextColor);
        const success = colorToHex(Theme.successColor);
        const danger = colorToHex(Theme.dangerColor);

        return "/* Generated by Quickshell. Do not edit. */\n"
            + ":root {\n"
            + "  color-scheme: " + (Theme.lightMode ? "light" : "dark") + ";\n"
            + "  --spice-main: " + background + ";\n"
            + "  --spice-base: " + background + ";\n"
            + "  --spice-sidebar: " + surface + ";\n"
            + "  --spice-player: " + surface + ";\n"
            + "  --spice-card: " + selected + ";\n"
            + "  --spice-shadow: " + background + ";\n"
            + "  --spice-main-elevated: " + selected + ";\n"
            + "  --spice-highlight: " + selected + ";\n"
            + "  --spice-highlight-elevated: " + border + ";\n"
            + "  --spice-tab-active: " + selected + ";\n"
            + "  --spice-notification: " + selected + ";\n"
            + "  --spice-misc: " + border + ";\n"
            + "  --spice-overlay0: " + muted + ";\n"
            + "  --spice-overlay1: " + secondary + ";\n"
            + "  --spice-overlay2: " + text + ";\n"
            + "  --spice-text: " + text + ";\n"
            + "  --spice-subtext: " + secondary + ";\n"
            + "  --spice-button: " + accent + ";\n"
            + "  --spice-button-active: " + accentHover + ";\n"
            + "  --spice-button-disabled: " + muted + ";\n"
            + "  --spice-selected-row: " + selected + ";\n"
            + "  --spice-green: " + success + ";\n"
            + "  --spice-red: " + danger + ";\n"
            + "  --spice-notification-error: " + danger + ";\n"
            + "  --background-base: " + background + ";\n"
            + "  --background-elevated-base: " + surface + ";\n"
            + "  --background-elevated-highlight: " + selected + ";\n"
            + "  --background-elevated-press: " + border + ";\n"
            + "  --background-highlight: " + selected + ";\n"
            + "  --background-tinted-base: " + selected + ";\n"
            + "  --background-tinted-highlight: " + border + ";\n"
            + "  --text-base: " + text + ";\n"
            + "  --text-subdued: " + secondary + ";\n"
            + "  --essential-base: " + text + ";\n"
            + "  --essential-subdued: " + muted + ";\n"
            + "  --essential-bright-accent: " + accent + ";\n"
            + "  --essential-positive: " + success + ";\n"
            + "  --essential-negative: " + danger + ";\n"
            + "  --decorative-base: " + accentText + ";\n"
            + "}\n";
    }

    function renderBtopTheme(): string {
        const background = colorToHex(Theme.shellBackgroundColor);
        const surface = colorToHex(Theme.panelSurfaceColor);
        const selected = colorToHex(Theme.selectedSurfaceColor);
        const border = colorToHex(Theme.surfaceBorderColor);
        const text = colorToHex(Theme.primaryTextColor);
        const secondary = colorToHex(Theme.secondaryTextColor);
        const muted = colorToHex(Theme.mutedTextColor);
        const accent = colorToHex(Theme.accentColor);
        const accentHover = colorToHex(Theme.accentHoverColor);
        const success = colorToHex(Theme.successColor);
        const danger = colorToHex(Theme.dangerColor);

        return "# Generated by Quickshell. Do not edit.\n"
            + "theme[main_bg]=\"" + background + "\"\n"
            + "theme[main_fg]=\"" + text + "\"\n"
            + "theme[title]=\"" + text + "\"\n"
            + "theme[hi_fg]=\"" + accent + "\"\n"
            + "theme[selected_bg]=\"" + selected + "\"\n"
            + "theme[selected_fg]=\"" + text + "\"\n"
            + "theme[inactive_fg]=\"" + muted + "\"\n"
            + "theme[graph_text]=\"" + secondary + "\"\n"
            + "theme[proc_misc]=\"" + accentHover + "\"\n"
            + "theme[cpu_box]=\"" + accent + "\"\n"
            + "theme[mem_box]=\"" + success + "\"\n"
            + "theme[net_box]=\"" + accentHover + "\"\n"
            + "theme[proc_box]=\"" + secondary + "\"\n"
            + "theme[div_line]=\"" + border + "\"\n"
            + "theme[temp_start]=\"" + success + "\"\n"
            + "theme[temp_mid]=\"" + accentHover + "\"\n"
            + "theme[temp_end]=\"" + danger + "\"\n"
            + "theme[cpu_start]=\"" + success + "\"\n"
            + "theme[cpu_mid]=\"" + accent + "\"\n"
            + "theme[cpu_end]=\"" + danger + "\"\n"
            + "theme[free_start]=\"" + danger + "\"\n"
            + "theme[free_mid]=\"" + accent + "\"\n"
            + "theme[free_end]=\"" + success + "\"\n"
            + "theme[cached_start]=\"" + surface + "\"\n"
            + "theme[cached_mid]=\"" + accent + "\"\n"
            + "theme[cached_end]=\"" + success + "\"\n"
            + "theme[available_start]=\"" + danger + "\"\n"
            + "theme[available_mid]=\"" + accent + "\"\n"
            + "theme[available_end]=\"" + accentHover + "\"\n"
            + "theme[used_start]=\"" + success + "\"\n"
            + "theme[used_mid]=\"" + accent + "\"\n"
            + "theme[used_end]=\"" + danger + "\"\n"
            + "theme[download_start]=\"" + muted + "\"\n"
            + "theme[download_mid]=\"" + accent + "\"\n"
            + "theme[download_end]=\"" + success + "\"\n"
            + "theme[upload_start]=\"" + muted + "\"\n"
            + "theme[upload_mid]=\"" + accentHover + "\"\n"
            + "theme[upload_end]=\"" + danger + "\"\n"
            + "theme[process_start]=\"" + success + "\"\n"
            + "theme[process_mid]=\"" + accent + "\"\n"
            + "theme[process_end]=\"" + danger + "\"\n";
    }

    function renderCavaTheme(): string {
        return "# Generated by Quickshell. Do not edit.\n"
            + "[color]\n"
            + "background = '" + colorToHex(Theme.shellBackgroundColor) + "'\n"
            + "foreground = '" + colorToHex(Theme.accentColor) + "'\n"
            + "gradient = 1\n"
            + "gradient_color_1 = '" + colorToHex(Theme.successColor) + "'\n"
            + "gradient_color_2 = '" + colorToHex(Theme.accentColor) + "'\n"
            + "gradient_color_3 = '" + colorToHex(Theme.accentHoverColor) + "'\n"
            + "gradient_color_4 = '" + colorToHex(Theme.dangerColor) + "'\n";
    }

    function updateVesktopCss(generatedBlock: string): void {
        let existing = vesktopQuickCssFile.text();
        const blockStart = existing.indexOf(vesktopBlockStart);
        const blockEnd = existing.indexOf(vesktopBlockEnd);
        if (blockStart >= 0 && blockEnd >= blockStart) {
            existing = existing.slice(0, blockStart)
                + existing.slice(blockEnd + vesktopBlockEnd.length);
        }
        existing = existing.trim();
        vesktopQuickCssFile.setText((existing === "" ? "" : existing + "\n\n")
            + generatedBlock);
    }

    function prepareThemeDirectory(): void {
        if (!directoryPrepared && !directoryPreparation.running)
            directoryPreparation.running = true;
    }

    function exportApplicationThemes(): void {
        if (!directoryPrepared)
            return;
        spotifyThemeFile.setText(renderSpotifyCss());
        btopThemeFile.setText(renderBtopTheme());
        cavaThemeFile.setText(renderCavaTheme());
        updateVesktopCss(renderVesktopCss());
    }

    FileView {
        id: spotifyThemeFile
        path: root.spotifyThemePath
        atomicWrites: true
        printErrors: true
    }

    FileView {
        id: vesktopQuickCssFile
        path: root.vesktopQuickCssPath
        blockLoading: true
        atomicWrites: false
        printErrors: true
    }

    FileView {
        id: btopThemeFile
        path: root.btopThemePath
        atomicWrites: true
        printErrors: true
    }

    FileView {
        id: cavaThemeFile
        path: root.cavaThemePath
        atomicWrites: false
        printErrors: true
    }

    Process {
        id: directoryPreparation
        command: ["mkdir", "-p", root.themeDirectory,
            root.configHome + "/btop/themes",
            root.configHome + "/cava/themes"]
        onExited: exitCode => {
            if (exitCode !== 0)
                return;
            root.directoryPrepared = true;
            root.preparationCompleted();
        }
    }
}
