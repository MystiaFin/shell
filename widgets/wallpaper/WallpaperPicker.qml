import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import "../../components/state"
import "../../components/theme"
import "../../services"

Item {
    id: root

    property url selectedSource: WallpaperService.source
    readonly property bool hasPendingSelection: selectedSource.toString()
        !== WallpaperService.source.toString()
    signal moveRequested()

    focus: OverlayState.wallpaperPickerVisible
    Keys.onEscapePressed: OverlayState.hideWallpaperPicker()

    Connections {
        target: OverlayState

        function onWallpaperPickerVisibleChanged() {
            if (OverlayState.wallpaperPickerVisible)
                root.selectedSource = WallpaperService.source;
        }
    }

    FolderListModel {
        id: wallpaperModel

        folder: WallpaperService.directory
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.JPEG", "*.PNG", "*.WEBP"]
        showDirs: false
        showDotAndDotDot: false
        sortField: FolderListModel.Name
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 22
        }
        spacing: 16

        WallpaperPickerHeader {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            imageCount: wallpaperModel.count
            directoryPath: WallpaperService.wallpaperDirectoryDisplayPath
            onCloseRequested: OverlayState.hideWallpaperPicker()
            onMoveRequested: root.moveRequested()
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 18
            color: Theme.panelSurfaceColor
            clip: true

            GridView {
                id: wallpaperGrid

                anchors {
                    fill: parent
                    margins: 10
                }
                model: wallpaperModel
                cellWidth: width / (width >= 620 ? 3 : 2)
                cellHeight: 142
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                delegate: WallpaperCard {
                    required property url fileUrl
                    required property string fileName

                    width: wallpaperGrid.cellWidth
                    height: wallpaperGrid.cellHeight
                    source: fileUrl
                    name: fileName
                    selected: root.selectedSource.toString() === fileUrl.toString()
                    onSelectionRequested: root.selectedSource = fileUrl
                }
            }

            Column {
                visible: wallpaperModel.status === FolderListModel.Ready
                    && wallpaperModel.count === 0
                anchors.centerIn: parent
                spacing: 8

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Icons.emptyFolder
                    color: Theme.mutedTextColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 34
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No wallpapers found"
                    color: Theme.primaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Add images to " + WallpaperService.wallpaperDirectoryDisplayPath
                    color: Theme.mutedTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 11
                }
            }
        }

        WallpaperPickerFooter {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            hasPendingSelection: root.hasPendingSelection
            onApplyRequested: WallpaperService.setWallpaper(root.selectedSource)
        }
    }
}
