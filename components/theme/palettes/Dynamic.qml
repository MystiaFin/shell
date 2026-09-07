import Quickshell
import QtQuick
import "../../../services"

QtObject {
    id: root

    readonly property real vibrancySaturationWeight: 1.4
    readonly property real vibrancyTargetLuminance: 0.52
    readonly property real vibrancyLuminancePenalty: 0.35
    readonly property real maximumToneSaturation: 0.82
    readonly property real lightModeThreshold: 0.50
    readonly property int quantizerDepth: 4
    readonly property int quantizerRescaleSize: 64

    readonly property var palette: quantizer.colors
    readonly property color baseColor: darkestColor(palette)
    readonly property color accentSeed: mostVibrantColor(palette)
    readonly property real wallpaperBrightness: averageLuminance(palette)
    readonly property bool automaticLightMode: wallpaperBrightness >= lightModeThreshold
    readonly property bool lightMode: modeOverride >= 0
        ? modeOverride === 1 : automaticLightMode
    property int modeOverride: -1
    readonly property var lightPalette: buildPalette(true)
    readonly property var darkPalette: buildPalette(false)
    readonly property var activePalette: lightMode ? lightPalette : darkPalette

    readonly property color foregroundColor: activePalette.background
    readonly property color highlightColor: activePalette.selectedSurface
    readonly property color windowColor: "transparent"
    readonly property color maskColor: activePalette.primaryText
    readonly property color textColor: activePalette.primaryText
    readonly property color secondaryTextColor: activePalette.secondaryText
    readonly property color itemHoverColor: activePalette.hoverSurface
    readonly property color searchBackgroundColor: activePalette.surface
    readonly property color searchBorderColor: activePalette.border
    readonly property color placeholderTextColor: activePalette.mutedText
    readonly property color wallpaperFallbackColor: activePalette.background
    readonly property color accentColor: activePalette.accent
    readonly property color accentHoverColor: activePalette.accentHover
    readonly property color accentTextColor: activePalette.onAccent
    readonly property color successColor: activePalette.success
    readonly property color dangerColor: activePalette.danger

    function toggleMode(): void {
        modeOverride = lightMode ? 0 : 1;
    }

    property Connections wallpaperConnections: Connections {
        target: WallpaperService
        function onSourceChanged(): void { root.modeOverride = -1; }
    }

    function luminance(colorValue: color): real {
        return colorValue.r * 0.2126 + colorValue.g * 0.7152 + colorValue.b * 0.0722;
    }

    function averageLuminance(colors): real {
        if (!colors || colors.length === 0)
            return 0;

        let total = 0;
        for (let index = 0; index < colors.length; index++)
            total += luminance(colors[index]);
        return total / colors.length;
    }

    function saturation(colorValue: color): real {
        const maximum = Math.max(colorValue.r, colorValue.g, colorValue.b);
        const minimum = Math.min(colorValue.r, colorValue.g, colorValue.b);
        return maximum - minimum;
    }

    function darkestColor(colors): color {
        if (!colors || colors.length === 0)
            return "#11111b";

        let selected = colors[0];
        let selectedScore = luminance(selected);
        for (let index = 1; index < colors.length; index++) {
            const score = luminance(colors[index]);
            if (score < selectedScore) {
                selected = colors[index];
                selectedScore = score;
            }
        }
        return selected;
    }

    function mostVibrantColor(colors): color {
        if (!colors || colors.length === 0)
            return "#89b4fa";

        let selected = colors[0];
        let selectedScore = -1;
        for (let index = 0; index < colors.length; index++) {
            const colorValue = colors[index];
            const brightness = luminance(colorValue);
            const score = saturation(colorValue) * vibrancySaturationWeight
                - Math.abs(brightness - vibrancyTargetLuminance)
                    * vibrancyLuminancePenalty;
            if (score > selectedScore) {
                selected = colorValue;
                selectedScore = score;
            }
        }
        return selected;
    }

    function tone(colorValue: color, lightness: real,
            minimumSaturation: real): color {
        const hue = colorValue.hslHue >= 0 ? colorValue.hslHue : 0;
        const nextSaturation = Math.max(minimumSaturation,
            Math.min(maximumToneSaturation, colorValue.hslSaturation));
        return Qt.hsla(hue, nextSaturation, lightness, 1);
    }

    function mix(first: color, second: color, amount: real): color {
        return Qt.rgba(
            first.r + (second.r - first.r) * amount,
            first.g + (second.g - first.g) * amount,
            first.b + (second.b - first.b) * amount,
            1
        );
    }

    function semanticColor(seed: color, accent: color, light: bool): color {
        return tone(mix(seed, accent, 0.20), light ? 0.42 : 0.70, 0.48);
    }

    function buildPalette(light: bool): var {
        const background = tone(baseColor, light ? 0.94 : 0.075,
            light ? 0.08 : 0.30);
        const surface = tone(baseColor, light ? 0.88 : 0.12,
            light ? 0.10 : 0.28);
        const accent = tone(accentSeed, light ? 0.42 : 0.68,
            Math.max(0.58, saturation(accentSeed)));
        const primaryText = tone(baseColor, light ? 0.10 : 0.91, 0.10);
        const secondaryText = tone(baseColor, light ? 0.30 : 0.72, 0.14);
        const mutedText = tone(baseColor, light ? 0.42 : 0.52, 0.16);
        const border = mix(surface, accent, light ? 0.26 : 0.32);

        return {
            light: light,
            background: background,
            surface: surface,
            hoverSurface: mix(surface, accent, light ? 0.12 : 0.20),
            selectedSurface: mix(surface, accent, light ? 0.20 : 0.15),
            border: border,
            primaryText: primaryText,
            secondaryText: secondaryText,
            mutedText: mutedText,
            accent: accent,
            accentHover: tone(accentSeed, light ? 0.34 : 0.78,
                Math.max(0.48, saturation(accentSeed))),
            onAccent: luminance(accent) > 0.56
                ? tone(baseColor, 0.08, 0.12)
                : tone(baseColor, 0.96, 0.08),
            success: semanticColor("#a6e3a1", accent, light),
            danger: semanticColor("#f38ba8", accent, light)
        };
    }

    property ColorQuantizer quantizer: ColorQuantizer {
        source: WallpaperService.source
        depth: root.quantizerDepth
        rescaleSize: root.quantizerRescaleSize
    }
}
