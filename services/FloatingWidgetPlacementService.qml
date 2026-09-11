pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property int sampleLongEdge: 120
    readonly property int cardGap: 12
    readonly property int maximumCachedAnalyses: 6
    property var pendingRequests: []
    property var retryRequests: []
    property var activeRequest: null
    property var latestGenerations: ({})
    property int nextGeneration: 0
    property bool requestTimedOut: false
    property bool processExited: false
    property bool outputFinished: false
    property int processExitCode: -1
    property var analysisCache: ({})
    property var analysisCacheKeys: []

    signal overviewPlacementReady(string key, string source, var placement)

    function requestOverviewPlacement(key: string, source: url,
            screenWidth: real, screenHeight: real, usableArea: rect,
            textColor: color, clockSize: size, weatherSize: size,
            calendarSize: size, resourceSize: size,
            gpuAvailable: bool): void {
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
            resourceSize: resourceSize,
            gpuAvailable: gpuAvailable,
            sampleWidth: sampleWidth,
            sampleHeight: sampleHeight,
            pixelCacheKey: sourceString + "|" + sampleWidth + "x" + sampleHeight,
            generation: ++nextGeneration,
            retryCount: 0
        };

        const generations = Object.assign({}, latestGenerations);
        generations[key] = request.generation;
        latestGenerations = generations;
        pendingRequests = pendingRequests.filter(item => item.key !== key);
        pendingRequests = pendingRequests.concat(request);
        startNextRequest();
    }

    function startNextRequest(): void {
        if (activeRequest || analyzer.running || pendingRequests.length === 0)
            return;

        activeRequest = pendingRequests[0];
        pendingRequests = pendingRequests.slice(1);
        const cachedAnalysis = analysisCache[activeRequest.pixelCacheKey];
        if (cachedAnalysis) {
            Qt.callLater(() => finishRequest(true, cachedAnalysis));
            return;
        }

        requestTimedOut = false;
        processExited = false;
        outputFinished = false;
        processExitCode = -1;
        const geometry = activeRequest.sampleWidth + "x" + activeRequest.sampleHeight;
        analyzer.command = ["magick", activeRequest.path, "-auto-orient",
            "-resize", geometry + "^", "-gravity", "center", "-extent", geometry,
            "-colorspace", "sRGB", "-depth", "8", "rgb:-"];
        analyzer.running = true;
        analysisTimeout.restart();
    }

    function buildAnalysis(data: var, request: var): var {
        const bytes = new Uint8Array(data);
        const pixelCount = request.sampleWidth * request.sampleHeight;
        if (bytes.length !== pixelCount * 3)
            return null;

        const pixels = new Array(pixelCount);
        for (let index = 0; index < pixelCount; ++index) {
            const byteIndex = index * 3;
            pixels[index] = (bytes[byteIndex] * 0.2126
                + bytes[byteIndex + 1] * 0.7152
                + bytes[byteIndex + 2] * 0.0722) / 255;
        }

        const squared = new Array(pixelCount);
        const detail = new Array(pixelCount);
        for (let y = 0; y < request.sampleHeight; ++y) {
            for (let x = 0; x < request.sampleWidth; ++x) {
                const index = y * request.sampleWidth + x;
                const value = pixels[index];
                squared[index] = value * value;
                detail[index] = (x > 0 ? Math.abs(value - pixels[index - 1]) : 0)
                    + (y > 0 ? Math.abs(value
                        - pixels[index - request.sampleWidth]) : 0);
            }
        }
        return {
            stride: request.sampleWidth + 1,
            luminance: buildIntegral(pixels, request.sampleWidth,
                request.sampleHeight),
            squared: buildIntegral(squared, request.sampleWidth,
                request.sampleHeight),
            detail: buildIntegral(detail, request.sampleWidth,
                request.sampleHeight)
        };
    }

    function luminance(colorValue: color): real {
        return colorValue.r * 0.2126 + colorValue.g * 0.7152
            + colorValue.b * 0.0722;
    }

    function cacheAnalysis(key: string, integrals: var): void {
        const nextCache = Object.assign({}, analysisCache);
        let nextKeys = analysisCacheKeys.filter(cachedKey => cachedKey !== key);
        nextCache[key] = integrals;
        nextKeys.push(key);
        while (nextKeys.length > maximumCachedAnalyses)
            delete nextCache[nextKeys.shift()];
        analysisCache = nextCache;
        analysisCacheKeys = nextKeys;
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
                const placement = { x: x, y: y, width: layout.width,
                    height: layout.height, cards: cards,
                    score: score };
                let insertionIndex = placements.length;
                while (insertionIndex > 0
                        && placements[insertionIndex - 1].score < score)
                    --insertionIndex;
                if (insertionIndex < limit) {
                    placements.splice(insertionIndex, 0, placement);
                    if (placements.length > limit)
                        placements.pop();
                }
            }
        }

        return placements;
    }

    function overlaps(first: var, second: var, margin: int): bool {
        return first.x < second.x + second.width + margin
            && first.x + first.width + margin > second.x
            && first.y < second.y + second.height + margin
            && first.y + first.height + margin > second.y;
    }

    function placementResult(orientation: string, joined: bool,
            groupPlacement: var, clockPlacement: var, request: var,
            resourcePlacement: var): var {
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
        for (let index = 0; index < resourcePlacement.cards.length; ++index) {
            const card = resourcePlacement.cards[index];
            positions[card.name] = {
                xRatio: card.x / request.sampleWidth,
                yRatio: card.y / request.sampleHeight
            };
        }
        return { orientation: orientation, clockJoined: joined,
            positions: positions };
    }

    function calculatePlacement(request: var, integrals: var): var {
        const width = request.sampleWidth;
        const height = request.sampleHeight;
        const boundsX = Math.max(0, Math.min(width, Math.round(
            request.usableArea.x / request.screenWidth * width)));
        const boundsY = Math.max(0, Math.min(height, Math.round(
            request.usableArea.y / request.screenHeight * height)));
        const boundsRight = Math.max(boundsX, Math.min(width, Math.round(
            (request.usableArea.x + request.usableArea.width)
                / request.screenWidth * width)));
        const boundsBottom = Math.max(boundsY, Math.min(height, Math.round(
            (request.usableArea.y + request.usableArea.height)
                / request.screenHeight * height)));
        const bounds = {
            x: boundsX,
            y: boundsY,
            width: boundsRight - boundsX,
            height: boundsBottom - boundsY
        };
        const gap = Math.max(1, Math.round(cardGap
            / request.screenWidth * width));
        const clockSize = sampleSize(request.clockSize, request);
        const weatherSize = sampleSize(request.weatherSize, request);
        const calendarSize = sampleSize(request.calendarSize, request);
        const clock = Object.assign({ name: "clock" }, clockSize);
        const weather = Object.assign({ name: "weather" }, weatherSize);
        const calendar = Object.assign({ name: "calendar" }, calendarSize);
        const resourceSize = sampleSize(request.resourceSize, request);
        const resourceCards = [
            Object.assign({ name: "cpuTemperature" }, resourceSize),
            Object.assign({ name: "cpuUsage" }, resourceSize)
        ];
        if (request.gpuAvailable)
            resourceCards.push(Object.assign({ name: "gpuTemperature" },
                resourceSize));
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

        if (!best)
            return null;

        const resourceLayouts = [
            horizontalLayout(resourceCards, gap),
            verticalLayout(resourceCards, gap)
        ];
        const occupied = [best.group];
        if (best.clock)
            occupied.push(best.clock);
        let resourcePlacement = null;
        let resourceScore = -Infinity;
        for (let index = 0; index < resourceLayouts.length; ++index) {
            const candidates = bestPlacements(resourceLayouts[index], bounds,
                request, integrals, 64, false, true);
            for (let candidateIndex = 0; candidateIndex < candidates.length;
                    ++candidateIndex) {
                const candidate = candidates[candidateIndex];
                let overlapPenalty = 0;
                for (let occupiedIndex = 0; occupiedIndex < occupied.length;
                        ++occupiedIndex) {
                    overlapPenalty += intersectionArea(candidate,
                        occupied[occupiedIndex])
                        / (candidate.width * candidate.height) * 20;
                    if (overlaps(candidate, occupied[occupiedIndex], gap * 2))
                        overlapPenalty += 2;
                }
                const score = candidate.score - overlapPenalty;
                if (score > resourceScore) {
                    resourceScore = score;
                    resourcePlacement = candidate;
                }
            }
        }

        return resourcePlacement ? placementResult(best.orientation, best.joined,
            best.group, best.clock, request, resourcePlacement) : null;
    }

    function finishRequest(success: bool, integrals: var): void {
        const request = activeRequest;
        if (!request)
            return;

        analysisTimeout.stop();
        if (success) {
            if (!analysisCache[request.pixelCacheKey])
                cacheAnalysis(request.pixelCacheKey, integrals);
            if (latestGenerations[request.key] === request.generation) {
                const result = calculatePlacement(request, integrals);
                if (result)
                    overviewPlacementReady(request.key, request.source, result);
            }
        } else {
            console.warn("Could not analyze wallpaper for Desktop Overview:",
                request.source, analyzerError.text.trim());
            if (request.retryCount < 2
                    && latestGenerations[request.key] === request.generation) {
                request.retryCount++;
                retryRequests = retryRequests.concat(request);
                retryDelay.restart();
            }
        }

        activeRequest = null;
        Qt.callLater(startNextRequest);
    }

    function tryFinishProcess(): void {
        if (!activeRequest || !processExited || !outputFinished)
            return;
        const integrals = !requestTimedOut && processExitCode === 0
            ? buildAnalysis(analyzerOutput.data, activeRequest) : null;
        finishRequest(integrals !== null, integrals);
    }

    Process {
        id: analyzer
        stdout: StdioCollector {
            id: analyzerOutput
            onStreamFinished: {
                root.outputFinished = true;
                root.tryFinishProcess();
            }
        }
        stderr: StdioCollector { id: analyzerError }
        onExited: (exitCode, exitStatus) => {
            root.processExitCode = exitCode;
            root.processExited = true;
            root.tryFinishProcess();
        }
    }

    Timer {
        id: analysisTimeout
        interval: 15000
        onTriggered: {
            root.requestTimedOut = true;
            analyzer.running = false;
        }
    }

    Timer {
        id: retryDelay
        interval: 300
        onTriggered: {
            const retries = root.retryRequests.filter(request =>
                root.latestGenerations[request.key] === request.generation);
            root.retryRequests = [];
            root.pendingRequests = root.pendingRequests.concat(retries);
            root.startNextRequest();
        }
    }
}
