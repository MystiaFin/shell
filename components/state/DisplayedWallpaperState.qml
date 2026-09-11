pragma Singleton

import Quickshell

Singleton {
    property var sources: ({})

    function setSource(screenName: string, source: url): void {
        const next = Object.assign({}, sources);
        next[screenName] = source.toString();
        sources = next;
    }

    function sourceForScreen(screenName: string): string {
        return sources[screenName] || "";
    }
}
