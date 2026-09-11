pragma Singleton

import Quickshell

Singleton {
    property var sources: ({})
    property var transitioningScreens: ({})

    function setSource(screenName: string, source: url): void {
        const next = Object.assign({}, sources);
        next[screenName] = source.toString();
        sources = next;
    }

    function sourceForScreen(screenName: string): string {
        return sources[screenName] || "";
    }

    function setTransitioning(screenName: string, transitioning: bool): void {
        const next = Object.assign({}, transitioningScreens);
        next[screenName] = transitioning;
        transitioningScreens = next;
    }

    function isTransitioning(screenName: string): bool {
        return transitioningScreens[screenName] === true;
    }
}
