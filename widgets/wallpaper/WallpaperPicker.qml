import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import Qt.labs.folderlistmodel
import "../../components/state"
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property bool shown
    required property int requestSerial
    required property Item wallpaperSourceItem
    required property rect wallpaperRect
    property alias focusTarget: keyHandler
    readonly property real blurMargin: 48
    readonly property real cropY: Math.max(0,
        wallpaperRect.y - blurMargin)
    readonly property real cropBottom: Math.min(wallpaperSourceItem.height,
        wallpaperRect.y + wallpaperRect.height + blurMargin)

    function selectCurrentWallpaper(): void {
        if (wallpaperModel.count === 0)
            return;

        const currentSource = WallpaperService.source.toString();
        let selectedIndex = 0;
        for (let index = 0; index < wallpaperModel.count; index++) {
            if (wallpaperModel.get(index, "fileUrl").toString() === currentSource) {
                selectedIndex = index;
                break;
            }
        }
        carousel.currentIndex = selectedIndex;
    }

    function applySelection(): void {
        if (wallpaperModel.count === 0 || carousel.currentIndex < 0)
            return;

        WallpaperService.setWallpaper(
            wallpaperModel.get(carousel.currentIndex, "fileUrl"));
        OverlayState.hideWallpaperPicker();
    }

    function moveSelection(forward: bool): void {
        if (wallpaperModel.count < 2)
            return;
        if (forward)
            carousel.incrementCurrentIndex();
        else
            carousel.decrementCurrentIndex();
    }

    opacity: shown ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    FolderListModel {
        id: wallpaperModel

        folder: WallpaperService.directory
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.JPEG", "*.PNG", "*.WEBP"]
        showDirs: false
        showDotAndDotDot: false
        sortField: FolderListModel.Name

        onStatusChanged: {
            if (status === FolderListModel.Ready && root.shown)
                Qt.callLater(root.selectCurrentWallpaper);
        }
    }

    onRequestSerialChanged: {
        if (!shown)
            return;
        Qt.callLater(() => {
            root.selectCurrentWallpaper();
            keyHandler.forceActiveFocus();
        });
    }

    onShownChanged: {
        if (!shown)
            return;
        Qt.callLater(() => {
            root.selectCurrentWallpaper();
            keyHandler.forceActiveFocus();
        });
    }

    ClippingRectangle {
        anchors.fill: parent
        radius: 0
        color: Theme.panelSurfaceColor
        contentUnderBorder: true

        ShaderEffectSource {
            id: wallpaperCrop

            x: 0
            y: root.cropY - root.wallpaperRect.y
            width: root.width
            height: Math.max(1, root.cropBottom - root.cropY)
            sourceItem: root.wallpaperSourceItem
            hideSource: true
            sourceRect: Qt.rect(
                0,
                root.cropY,
                width,
                height)
            textureSize: Qt.size(width, height)
            live: true
            smooth: true
        }

        MultiEffect {
            anchors.fill: wallpaperCrop
            source: wallpaperCrop
            autoPaddingEnabled: false
            blurEnabled: true
            blur: 1
            blurMax: 64
            blurMultiplier: 1.6
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.panelSurfaceColor
            opacity: 0.48
        }

        PathView {
            id: carousel

            anchors.fill: parent
            anchors.margins: 24
            model: wallpaperModel
            pathItemCount: 7
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            highlightRangeMode: PathView.StrictlyEnforceRange
            highlightMoveDuration: 320
            snapMode: PathView.SnapOneItem

            delegate: WallpaperCard {
                required property int index
                required property url fileUrl

                width: Math.min(360, root.width * 0.34)
                height: Math.min(240, root.height - 72)
                source: fileUrl
                prominence: PathView.prominence
                onSelectionRequested: carousel.currentIndex = index
            }

            path: Path {
                startX: -carousel.width * 0.12
                startY: carousel.height / 2
                PathAttribute { name: "prominence"; value: 0 }
                PathLine { x: carousel.width / 2; y: carousel.height / 2 }
                PathAttribute { name: "prominence"; value: 1 }
                PathLine { x: carousel.width * 1.12; y: carousel.height / 2 }
                PathAttribute { name: "prominence"; value: 0 }
            }
        }

        Column {
            visible: wallpaperModel.status === FolderListModel.Ready
                && wallpaperModel.count === 0
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "No wallpapers found"
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 16
                font.weight: Font.DemiBold
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: WallpaperService.wallpaperDirectoryDisplayPath
                color: Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 11
            }
        }
    }

    Item {
        id: keyHandler

        anchors.fill: parent
        focus: root.shown

        Keys.onPressed: event => {
            if (event.key === Qt.Key_H || event.key === Qt.Key_Left) {
                root.moveSelection(false);
            } else if (event.key === Qt.Key_L || event.key === Qt.Key_Right) {
                root.moveSelection(true);
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.applySelection();
            } else if (event.key === Qt.Key_Escape) {
                OverlayState.hideWallpaperPicker();
            } else {
                return;
            }
            event.accepted = true;
        }
    }
}
