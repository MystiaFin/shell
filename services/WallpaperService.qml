pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string homeDirectory: Quickshell.env("HOME")
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME")
        || homeDirectory + "/.config"
    readonly property string picturesDirectory: expandedPath(
        Quickshell.env("XDG_PICTURES_DIR") || homeDirectory + "/Pictures")
    readonly property string wallpaperDirectoryPath: picturesDirectory + "/Wallpapers"
    readonly property string wallpaperDirectoryDisplayPath:
        wallpaperDirectoryPath.indexOf(homeDirectory + "/") === 0
            ? "~" + wallpaperDirectoryPath.slice(homeDirectory.length)
            : wallpaperDirectoryPath
    readonly property url directory: localFileUrl(wallpaperDirectoryPath)
    readonly property url defaultSource: directory + "/wallpaper_2.jpg"
    property url source: {
        const savedSource = selectionFile.text().trim();
        return savedSource !== "" ? savedSource : defaultSource;
    }

    function setWallpaper(nextSource): void {
        source = nextSource;
        selectionFile.setText(source.toString());
    }

    function expandedPath(pathValue): string {
        let path = pathValue.trim();
        if ((path.startsWith("\"") && path.endsWith("\""))
                || (path.startsWith("'") && path.endsWith("'")))
            path = path.slice(1, -1);
        return path.split("${HOME}").join(homeDirectory)
            .split("$HOME").join(homeDirectory);
    }

    function localFileUrl(pathValue): string {
        return "file://" + pathValue.split("/")
            .map(part => encodeURIComponent(part)).join("/");
    }

    FileView {
        id: selectionFile

        path: root.configHome + "/quickshell/wallpaper-selection"
        printErrors: false
        atomicWrites: true
        blockLoading: true
    }
}
