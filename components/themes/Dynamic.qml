import Quickshell
import QtQuick
import "../../services"

QtObject {
    id: root

    readonly property var palette: quantizer.colors
    readonly property color baseColor: darkestColor(palette)
    readonly property color accentSeed: mostVibrantColor(palette)

    readonly property color foregroundColor: tone(baseColor, 0.075, 0.30)
    readonly property color highlightColor: mix(foregroundColor, accentColor, 0.15)
    readonly property color windowColor: "transparent"
    readonly property color maskColor: tone(baseColor, 0.90, 0.10)
    readonly property color textColor: tone(baseColor, 0.91, 0.10)
    readonly property color secondaryTextColor: tone(baseColor, 0.72, 0.14)
    readonly property color itemHoverColor: mix(foregroundColor, accentColor, 0.20)
    readonly property color searchBackgroundColor: tone(baseColor, 0.12, 0.28)
    readonly property color searchBorderColor: mix(searchBackgroundColor, accentColor, 0.32)
    readonly property color placeholderTextColor: tone(baseColor, 0.52, 0.16)
    readonly property color wallpaperFallbackColor: foregroundColor

    readonly property color accentColor: tone(accentSeed, 0.68,
        Math.max(0.58, saturation(accentSeed)))
    readonly property color highlightAccentColor: tone(accentSeed, 0.78,
        Math.max(0.48, saturation(accentSeed)))
    readonly property color blueColor: harmonize("#89b4fa", accentColor, 0.30)
    readonly property color greenColor: harmonize("#a6e3a1", accentColor, 0.24)
    readonly property color redColor: harmonize("#f38ba8", accentColor, 0.22)

    function luminance(colorValue: color): real {
        return colorValue.r * 0.2126 + colorValue.g * 0.7152 + colorValue.b * 0.0722;
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
            const score = saturation(colorValue) * 1.4
                - Math.abs(brightness - 0.52) * 0.35;
            if (score > selectedScore) {
                selected = colorValue;
                selectedScore = score;
            }
        }
        return selected;
    }

    function tone(colorValue: color, lightness: real, minimumSaturation: real): color {
        const hue = colorValue.hslHue >= 0 ? colorValue.hslHue : 0;
        const nextSaturation = Math.max(minimumSaturation,
            Math.min(0.82, colorValue.hslSaturation));
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

    function harmonize(semanticColor: color, wallpaperColor: color, amount: real): color {
        const blended = mix(semanticColor, wallpaperColor, amount);
        return tone(blended, 0.70, 0.48);
    }

    property ColorQuantizer quantizer: ColorQuantizer {
        source: WallpaperService.source
        depth: 4
        rescaleSize: 64
    }
}
