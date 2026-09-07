pragma Singleton

import Quickshell

Singleton {
    property var startedScreens: ({})
    property var revealedScreens: ({})

    function startSequence(screenName: string): void {
        const nextScreens = Object.assign({}, startedScreens);
        nextScreens[screenName] = true;
        startedScreens = nextScreens;
    }

    function sequenceStarted(screenName: string): bool {
        return startedScreens[screenName] === true;
    }

    function finishMaskReveal(screenName: string): void {
        const nextScreens = Object.assign({}, revealedScreens);
        nextScreens[screenName] = true;
        revealedScreens = nextScreens;
    }

    function maskRevealFinished(screenName: string): bool {
        return revealedScreens[screenName] === true;
    }
}
