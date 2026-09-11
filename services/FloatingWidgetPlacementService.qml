pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property int sampleLongEdge: 120
    readonly property int cardGap: 12
    property var pendingRequests: []
    property var activeRequest: null
    property var pixels: []
    property int parsedPixelCount: 0
    property bool requestTimedOut: false
    property var pixelCache: ({})

    signal overviewPlacementReady(string key, string source, var placement)

    function requestOverviewPlacement(key: string, source: url,
            screenWidth: real, screenHeight: real, usableArea: rect,
            textColor: color, clockSize: size, weatherSize: size,
            calendarSize: size): void {
        const sourceString = source.toString();
        if (!sourceString || !sourceString.startsWith("file://")
                || screenWidth <= 0 || screenHeight <= 0)
            return;

        const landscape = screenWidth >= screenHeight;
        const sampleWidth = landscape ? sampleLongEdge : Math.max(1,
            Math.round(sampleLongEdge * screenWidth / screenHeight));
        const sampleHeight = landscape ? Math.max(1,
            Math.round(sampleLongEdge * screenHeight / screenWidth))
            : sampleLongEdge;
        const request = {
            key: key,
            source: sourceString,
            path: decodeURIComponent(sourceString.replace(/^file:\/\//, "")),
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            usableArea: usableArea,
            textLuminance: luminance(textColor),
            clockSize: clockSize,
            weatherSize: weatherSize,
            calendarSize: calendarSize,
            sampleWidth: sampleWidth,
            sampleHeight: sampleHeight,
            pixelCacheKey: sourceString + "|" + sampleWidth + "x" + sampleHeight
        };

        pendingRequests = pendingRequests.filter(item => item.key !== key);
        pendingRequests = pendingRequests.concat(request);
        startNextRequest();
    }

    function startNextRequest(): void {
        if (activeRequest || analyzer.running || pendingRequests.length === 0)
            return;

        activeRequest = pendingRequests[0];
        pendingRequests = pendingRequests.slice(1);
        const cachedPixels = pixelCache[activeRequest.pixelCacheKey];
        if (cachedPixels) {
            pixels = cachedPixels;
            Qt.callLater(finishRequest);
            return;
        }

        pixels = new Array(activeRequest.sampleWidth * activeRequest.sampleHeight);
        parsedPixelCount = 0;
        requestTimedOut = false;
        const geometry = activeRequest.sampleWidth + "x" + activeRequest.sampleHeight;
        analyzer.command = ["magick", activeRequest.path, "-auto-orient",
            "-resize", geometry + "^", "-gravity", "center", "-extent", geometry,
            "-colorspace", "sRGB", "-depth", "8", "txt:-"];
        analyzer.running = true;
        analysisTimeout.restart();
    }

    function parsePixel(line: string): void {
        if (!activeRequest)
            return;

        const match = /^(\d+),(\d+):.*#([0-9A-Fa-f]{6})/.exec(line);
        if (!match)
            return;

        const x = Number(match[1]);
        const y = Number(match[2]);
        const rgb = match[3];
        const red = parseInt(rgb.slice(0, 2), 16) / 255;
        const green = parseInt(rgb.slice(2, 4), 16) / 255;
        const blue = parseInt(rgb.slice(4, 6), 16) / 255;
        const index = y * activeRequest.sampleWidth + x;
        if (pixels[index] === undefined)
            ++parsedPixelCount;
        pixels[index] = red * 0.2126 + green * 0.7152 + blue * 0.0722;
    }

    function luminance(colorValue: color): real {
        return colorValue.r * 0.2126 + colorValue.g * 0.7152
            + colorValue.b * 0.0722;
    }

    function buildIntegral(values: var, width: int, height: int): var {
        const stride = width + 1;
        const integral = new Array(stride * (height + 1)).fill(0);
        for (let y = 1; y <= height; ++y) {
            let rowSum = 0;
            for (let x = 1; x <= width; ++x) {
                rowSum += values[(y - 1) * width + x - 1];
                integral[y * stride + x]
                    = integral[(y - 1) * stride + x] + rowSum;
            }
        }
        return integral;
    }

    function rectangleSum(integral: var, stride: int, rectangle: var): real {
        const right = rectangle.x + rectangle.width;
        const bottom = rectangle.y + rectangle.height;
        return integral[bottom * stride + right]
            - integral[rectangle.y * stride + right]
            - integral[bottom * stride + rectangle.x]
            + integral[rectangle.y * stride + rectangle.x];
    }

    function regionStatistics(rectangle: var, integrals: var): var {
        const area = rectangle.width * rectangle.height;
        const mean = rectangleSum(integrals.luminance, integrals.stride,
            rectangle) / area;
        const squaredMean = rectangleSum(integrals.squared, integrals.stride,
            rectangle) / area;
        const deviation = Math.sqrt(Math.max(0, squaredMean - mean * mean));
        const detail = rectangleSum(integrals.detail, integrals.stride,
            rectangle) / area;
        return { mean: mean, deviation: deviation, detail: detail };
    }

    function cardScore(rectangle: var, request: var, integrals: var,
            textOnly: bool): real {
        const statistics = regionStatistics(rectangle, integrals);
        if (!textOnly)
            return -statistics.deviation * 12 - statistics.detail * 10;

        const contrast = (Math.max(request.textLuminance, statistics.mean) + 0.05)
            / (Math.min(request.textLuminance, statistics.mean) + 0.05);
        return Math.min(4, contrast) * 0.25
            - statistics.deviation * 6 - statistics.detail * 6;
    }

    function horizontalLayout(cards: var, gap: int): var {
        let width = 0;
        let height = 0;
        for (let index = 0; index < cards.length; ++index) {
            width += cards[index].width;
            height = Math.max(height, cards[index].height);
        }
        width += gap * (cards.length - 1);

        let x = 0;
        const result = [];
        for (let index = 0; index < cards.length; ++index) {
            const card = cards[index];
            result.push({ name: card.name, x: x,
                y: Math.round((height - card.height) / 2),
                width: card.width, height: card.height });
            x += card.width + gap;
        }
        return { width: width, height: height, cards: result, vertical: false };
    }

    function verticalLayout(cards: var, gap: int): var {
        let width = 0;
        let height = 0;
        for (let index = 0; index < cards.length; ++index) {
            width = Math.max(width, cards[index].width);
            height += cards[index].height;
        }
        height += gap * (cards.length - 1);

        let y = 0;
        const result = [];
        for (let index = 0; index < cards.length; ++index) {
            const card = cards[index];
            result.push({ name: card.name,
                x: Math.round((width - card.width) / 2), y: y,
                width: card.width, height: card.height });
            y += card.height + gap;
        }
        return { width: width, height: height, cards: result, vertical: true };
    }

    function sampleSize(sizeValue: size, request: var): var {
        return {
            width: Math.max(2, Math.round(sizeValue.width
                / request.screenWidth * request.sampleWidth)),
            height: Math.max(2, Math.round(sizeValue.height
                / request.screenHeight * request.sampleHeight))
        };
    }

    function offsetCards(layout: var, x: int, y: int,
            screenWidth: int): var {
        const alignRight = layout.vertical
            && x + layout.width / 2 >= screenWidth / 2;
        return layout.cards.map(card => ({
            name: card.name,
            x: x + (layout.vertical
                ? alignRight ? layout.width - card.width : 0
                : card.x),
            y: card.y + y,
            width: card.width,
            height: card.height
        }));
    }

    function intersectionArea(first: var, second: var): real {
        const width = Math.max(0, Math.min(first.x + first.width,
            second.x + second.width) - Math.max(first.x, second.x));
        const height = Math.max(0, Math.min(first.y + first.height,
            second.y + second.height) - Math.max(first.y, second.y));
        return width * height;
    }

    function bestPlacements(layout: var, bounds: var, request: var,
            integrals: var, limit: int, textOnly: bool,
            protectCenter: bool): var {
        const placements = [];
        const maximumX = bounds.x + bounds.width - layout.width;
        const maximumY = bounds.y + bounds.height - layout.height;
        if (maximumX < bounds.x || maximumY < bounds.y)
            return placements;

        for (let y = bounds.y; y <= maximumY; y += 2) {
            for (let x = bounds.x; x <= maximumX; x += 2) {
                const cards = offsetCards(layout, x, y,
                    request.sampleWidth);
                let score = 0;
                for (let index = 0; index < cards.length; ++index)
                    score += cardScore(cards[index], request, integrals,
                        textOnly);
                score /= cards.length;

                const surroundMargin = Math.max(2, Math.round(
                    Math.min(layout.width, layout.height) * 0.12));
                const surroundingRegion = {
                    x: Math.max(bounds.x, x - surroundMargin),
                    y: Math.max(bounds.y, y - surroundMargin),
                    width: Math.min(bounds.x + bounds.width,
                        x + layout.width + surroundMargin)
                        - Math.max(bounds.x, x - surroundMargin),
                    height: Math.min(bounds.y + bounds.height,
                        y + layout.height + surroundMargin)
                        - Math.max(bounds.y, y - surroundMargin)
                };
                const surroundingStatistics = regionStatistics(
                    surroundingRegion, integrals);
                score -= surroundingStatistics.deviation * 8
                    + surroundingStatistics.detail * 8;

                if (protectCenter) {
                    const protectedRegion = {
                        x: Math.round(request.sampleWidth * 0.25),
                        y: Math.round(request.sampleHeight * 0.16),
                        width: Math.round(request.sampleWidth * 0.5),
                        height: Math.round(request.sampleHeight * 0.68)
                    };
                    const overlapRatio = intersectionArea({ x: x, y: y,
                        width: layout.width, height: layout.height },
                        protectedRegion) / (layout.width * layout.height);
                    score -= overlapRatio * 5;
                }
                placements.push({ x: x, y: y, width: layout.width,
                    height: layout.height, cards: cards,
                    score: score });
            }
        }

        placements.sort((first, second) => second.score - first.score);
        return placements.slice(0, limit);
    }

    function overlaps(first: var, second: var, margin: int): bool {
        return first.x < second.x + second.width + margin
            && first.x + first.width + margin > second.x
            && first.y < second.y + second.height + margin
            && first.y + first.height + margin > second.y;
    }

    function placementResult(orientation: string, joined: bool,
            groupPlacement: var, clockPlacement: var, request: var): var {
        const positions = {};
        for (let index = 0; index < groupPlacement.cards.length; ++index) {
            const card = groupPlacement.cards[index];
            positions[card.name] = {
                xRatio: card.x / request.sampleWidth,
                yRatio: card.y / request.sampleHeight
            };
        }
        if (!joined) {
            positions.clock = {
                xRatio: clockPlacement.cards[0].x / request.sampleWidth,
                yRatio: clockPlacement.cards[0].y / request.sampleHeight
            };
        }
        return { orientation: orientation, clockJoined: joined,
            positions: positions };
    }

    function calculatePlacement(request: var): var {
        const width = request.sampleWidth;
        const height = request.sampleHeight;
        const squared = new Array(pixels.length);
        const detail = new Array(pixels.length);
        for (let y = 0; y < height; ++y) {
            for (let x = 0; x < width; ++x) {
                const index = y * width + x;
                const value = pixels[index];
                squared[index] = value * value;
                detail[index] = (x > 0 ? Math.abs(value - pixels[index - 1]) : 0)
                    + (y > 0 ? Math.abs(value - pixels[index - width]) : 0);
            }
        }
        const integrals = {
            stride: width + 1,
            luminance: buildIntegral(pixels, width, height),
            squared: buildIntegral(squared, width, height),
            detail: buildIntegral(detail, width, height)
        };
        const bounds = {
            x: Math.max(0, Math.round(request.usableArea.x
                / request.screenWidth * width)),
            y: Math.max(0, Math.round(request.usableArea.y
                / request.screenHeight * height)),
            width: Math.min(width, Math.round(request.usableArea.width
                / request.screenWidth * width)),
            height: Math.min(height, Math.round(request.usableArea.height
                / request.screenHeight * height))
        };
        const gap = Math.max(1, Math.round(cardGap
            / request.screenWidth * width));
        const clockSize = sampleSize(request.clockSize, request);
        const weatherSize = sampleSize(request.weatherSize, request);
        const calendarSize = sampleSize(request.calendarSize, request);
        const clock = Object.assign({ name: "clock" }, clockSize);
        const weather = Object.assign({ name: "weather" }, weatherSize);
        const calendar = Object.assign({ name: "calendar" }, calendarSize);
        const joinedLayouts = [
            { orientation: "horizontal",
                layout: horizontalLayout([clock, weather, calendar], gap) },
            { orientation: "vertical",
                layout: verticalLayout([clock, weather, calendar], gap) }
        ];
        const separateLayouts = [
            { orientation: "horizontal",
                layout: horizontalLayout([weather, calendar], gap) },
            { orientation: "vertical",
                layout: verticalLayout([weather, calendar], gap) }
        ];
        const clockLayout = horizontalLayout([clock], 0);
        const clockPlacements = bestPlacements(clockLayout, bounds, request,
            integrals, 24, true, true);
        let best = null;

        for (let index = 0; index < joinedLayouts.length; ++index) {
            const variant = joinedLayouts[index];
            const placements = bestPlacements(variant.layout, bounds, request,
                integrals, 1, false, true);
            if (placements.length === 0)
                continue;
            const score = placements[0].score + 0.2;
            if (!best || score > best.score)
                best = { score: score, orientation: variant.orientation,
                    joined: true, group: placements[0], clock: null };
        }

        for (let index = 0; index < separateLayouts.length; ++index) {
            const variant = separateLayouts[index];
            const groups = bestPlacements(variant.layout, bounds, request,
                integrals, 24, false, true);
            for (let groupIndex = 0; groupIndex < groups.length; ++groupIndex) {
                for (let clockIndex = 0; clockIndex < clockPlacements.length;
                        ++clockIndex) {
                    const group = groups[groupIndex];
                    const clockPlacement = clockPlacements[clockIndex];
                    if (overlaps(group, clockPlacement, gap * 2))
                        continue;
                    const score = (group.score * 2 + clockPlacement.score) / 3;
                    if (!best || score > best.score)
                        best = { score: score, orientation: variant.orientation,
                            joined: false, group: group, clock: clockPlacement };
                }
            }
        }

        return best ? placementResult(best.orientation, best.joined,
            best.group, best.clock, request) : null;
    }

    function finishRequest(): void {
        const request = activeRequest;
        if (!request)
            return;

        const cached = pixelCache[request.pixelCacheKey] === pixels;
        analysisTimeout.stop();
        const complete = !requestTimedOut && (cached || parsedPixelCount
            === request.sampleWidth * request.sampleHeight);
        if (complete) {
            if (!cached) {
                const nextCache = Object.assign({}, pixelCache);
                nextCache[request.pixelCacheKey] = pixels;
                pixelCache = nextCache;
            }
            const result = calculatePlacement(request);
            if (result)
                overviewPlacementReady(request.key, request.source, result);
        } else {
            console.warn("Could not analyze wallpaper for Desktop Overview:",
                request.source);
        }

        activeRequest = null;
        pixels = [];
        parsedPixelCount = 0;
        Qt.callLater(startNextRequest);
    }

    Process {
        id: analyzer
        stdout: SplitParser { onRead: data => root.parsePixel(data) }
        onExited: root.finishRequest()
    }

    Timer {
        id: analysisTimeout
        interval: 15000
        onTriggered: {
            root.requestTimedOut = true;
            analyzer.running = false;
        }
    }
}
