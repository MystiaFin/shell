pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property url directory: "file:///home/mystiafin/Pictures/Wallpapers"
    readonly property url defaultSource: directory + "/wallpaper_2.jpg"
    property url source: {
        const savedSource = selectionFile.text().trim();
        return savedSource !== "" ? savedSource : defaultSource;
    }

    function setWallpaper(nextSource): void {
        source = nextSource;
        selectionFile.setText(source.toString());
    }

    FileView {
        id: selectionFile

        path: Qt.resolvedUrl("../wallpaper-selection")
        printErrors: false
        atomicWrites: true
        blockLoading: true
    }
}
