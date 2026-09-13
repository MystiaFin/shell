pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel

Singleton {
    id: root

    readonly property string homeDirectory: Quickshell.env("HOME")
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME")
        || homeDirectory + "/.config"
    readonly property string wallpaperDirectoryPath: expandedPath(
        SettingsService.wallpaperDirectory)
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
        if (shuffleTimer.running)
            shuffleTimer.restart();
    }

    function chooseRandomWallpaper(): void {
        if (wallpaperModel.count < 1)
            return;

        let index = Math.floor(Math.random() * wallpaperModel.count);
        if (wallpaperModel.count > 1) {
            const current = source.toString();
            for (let attempt = 0; attempt < 4
                    && wallpaperModel.get(index, "fileUrl").toString() === current;
                    attempt++)
                index = Math.floor(Math.random() * wallpaperModel.count);
        }
        setWallpaper(wallpaperModel.get(index, "fileUrl"));
    }

    function expandedPath(pathValue): string {
        let path = (pathValue || "").trim();
        if ((path.startsWith("\"") && path.endsWith("\""))
                || (path.startsWith("'") && path.endsWith("'")))
            path = path.slice(1, -1);
        if (path === "~")
            path = homeDirectory;
        else if (path.startsWith("~/"))
            path = homeDirectory + path.slice(1);
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

    FolderListModel {
        id: wallpaperModel
        folder: root.directory
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp",
            "*.JPG", "*.JPEG", "*.PNG", "*.WEBP"]
        showDirs: false
        showDotAndDotDot: false
        sortField: FolderListModel.Name
    }

    Timer {
        id: shuffleTimer
        interval: Math.max(60000,
            SettingsService.wallpaperShuffleMinutes * 60000)
        repeat: true
        running: SettingsService.wallpaperShuffle && wallpaperModel.count > 1
        onTriggered: root.chooseRandomWallpaper()
    }
}
