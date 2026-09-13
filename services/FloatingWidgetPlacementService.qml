pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "floatingwidgets/WallpaperAnalysis.js" as WallpaperAnalysis
import "floatingwidgets/OverviewPlacement.js" as OverviewPlacement

Singleton {
    id: root

    readonly property int sampleLongEdge: 120
    readonly property int cardGap: 12
    readonly property int maximumCachedAnalyses: 6
    readonly property int maximumRetries: 2

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
    signal overviewPlacementFailed(string key, string source)

    function requestOverviewPlacement(options: var): void {
        const source = options.source.toString();
        if (!source || !source.startsWith("file://")
                || options.screenWidth <= 0 || options.screenHeight <= 0)
            return;

        const sampleSize = analysisSampleSize(options.screenWidth,
            options.screenHeight);
        const request = Object.assign({}, options, {
            source: source,
            path: decodeURIComponent(source.replace(/^file:\/\//, "")),
            textLuminance: WallpaperAnalysis.colorLuminance(options.textColor),
            sampleWidth: sampleSize.width,
            sampleHeight: sampleSize.height,
            cacheKey: source + "|" + sampleSize.width + "x" + sampleSize.height,
            generation: ++nextGeneration,
            retryCount: 0
        });

        const generations = Object.assign({}, latestGenerations);
        generations[request.key] = request.generation;
        latestGenerations = generations;

        // Keep only the newest pending request for each screen.
        pendingRequests = pendingRequests.filter(item => item.key !== request.key);
        pendingRequests = pendingRequests.concat(request);
        startNextRequest();
    }

    function analysisSampleSize(screenWidth: real, screenHeight: real): var {
        const landscape = screenWidth >= screenHeight;
        return {
            width: landscape ? sampleLongEdge : Math.max(1,
                Math.round(sampleLongEdge * screenWidth / screenHeight)),
            height: landscape ? Math.max(1,
                Math.round(sampleLongEdge * screenHeight / screenWidth))
                : sampleLongEdge
        };
    }

    function startNextRequest(): void {
        if (activeRequest || analyzer.running || pendingRequests.length === 0)
            return;

        activeRequest = pendingRequests[0];
        pendingRequests = pendingRequests.slice(1);

        const cached = analysisCache[activeRequest.cacheKey];
        if (cached) {
            Qt.callLater(() => finishRequest(true, cached));
            return;
        }

        resetProcessState();
        const geometry = activeRequest.sampleWidth + "x" + activeRequest.sampleHeight;
        analyzer.command = [
            "magick", activeRequest.path,
            "-auto-orient",
            "-resize", geometry + "^",
            "-gravity", "center",
            "-extent", geometry,
            "-colorspace", "sRGB",
            "-depth", "8",
            "rgb:-"
        ];
        analyzer.running = true;
        analysisTimeout.restart();
    }

    function resetProcessState(): void {
        requestTimedOut = false;
        processExited = false;
        outputFinished = false;
        processExitCode = -1;
    }

    function finishRequest(success: bool, analysis: var): void {
        const request = activeRequest;
        if (!request)
            return;

        analysisTimeout.stop();

        if (success) {
            cacheAnalysis(request.cacheKey, analysis);
            emitPlacementIfCurrent(request, analysis);
        } else {
            retryIfCurrent(request);
        }

        activeRequest = null;
        Qt.callLater(startNextRequest);
    }

    function emitPlacementIfCurrent(request: var, analysis: var): void {
        if (latestGenerations[request.key] !== request.generation)
            return;

        const placement = OverviewPlacement.calculate(request, analysis, cardGap);
        if (placement)
            overviewPlacementReady(request.key, request.source, placement);
        else
            overviewPlacementFailed(request.key, request.source);
    }

    function retryIfCurrent(request: var): void {
        console.warn("Could not analyze wallpaper for Desktop Overview:",
            request.source, analyzerError.text.trim());

        if (latestGenerations[request.key] !== request.generation)
            return;
        if (request.retryCount >= maximumRetries) {
            overviewPlacementFailed(request.key, request.source);
            return;
        }

        request.retryCount++;
        retryRequests = retryRequests.concat(request);
        retryDelay.restart();
    }

    function tryFinishProcess(): void {
        if (!activeRequest || !processExited || !outputFinished)
            return;

        const analysis = !requestTimedOut && processExitCode === 0
            ? WallpaperAnalysis.build(analyzerOutput.data,
                activeRequest.sampleWidth, activeRequest.sampleHeight)
            : null;
        finishRequest(analysis !== null, analysis);
    }

    function cacheAnalysis(key: string, analysis: var): void {
        if (analysisCache[key])
            return;

        const cache = Object.assign({}, analysisCache);
        const keys = analysisCacheKeys.slice();
        cache[key] = analysis;
        keys.push(key);

        while (keys.length > maximumCachedAnalyses)
            delete cache[keys.shift()];

        analysisCache = cache;
        analysisCacheKeys = keys;
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
