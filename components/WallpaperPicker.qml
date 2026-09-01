import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import "../services"

Item {
    id: root

    property url selectedSource: WallpaperService.source
    readonly property bool hasPendingSelection: selectedSource.toString()
        !== WallpaperService.source.toString()
    signal moveRequested()

    focus: WallpaperPickerState.visible
    Keys.onEscapePressed: WallpaperPickerState.hide()

    Connections {
        target: WallpaperPickerState

        function onVisibleChanged() {
            if (WallpaperPickerState.visible)
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

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            spacing: 12

            DragHandler {
                target: null
                onActiveChanged: if (active) root.moveRequested()
            }

            Rectangle {
                Layout.preferredWidth: 46
                Layout.preferredHeight: 46
                radius: 15
                color: Theme.statusBarAccentColor

                Text {
                    anchors.centerIn: parent
                    text: "󰸉"
                    color: Theme.statusBarBackgroundColor
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 22
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    text: "Wallpapers"
                    color: Theme.statusBarTextColor
                    font.family: "Poppins"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                }

                Text {
                    Layout.fillWidth: true
                    text: wallpaperModel.count + (wallpaperModel.count === 1 ? " image" : " images")
                        + " in ~/Pictures/Wallpapers"
                    color: Theme.statusBarMutedColor
                    font.family: "Poppins"
                    font.pixelSize: 11
                    elide: Text.ElideMiddle
                }
            }

            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: 12
                color: closeHover.hovered
                    ? Theme.statusBarRedColor
                    : Theme.statusBarSurfaceColor

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    color: closeHover.hovered
                        ? Theme.statusBarBackgroundColor
                        : Theme.statusBarTextColor
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 17
                }

                HoverHandler {
                    id: closeHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler { onTapped: WallpaperPickerState.hide() }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 18
            color: Theme.statusBarSurfaceColor
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

                delegate: Item {
                    id: wallpaperCard

                    required property url fileUrl
                    required property string fileName

                    width: wallpaperGrid.cellWidth
                    height: wallpaperGrid.cellHeight

                    Rectangle {
                        anchors {
                            fill: parent
                            margins: 5
                        }
                        radius: 14
                        color: cardHover.hovered
                            ? Theme.statusBarSurfaceBorderColor
                            : Theme.statusBarWorkspaceColor
                        border.width: root.selectedSource.toString() === wallpaperCard.fileUrl.toString()
                            ? 3 : 0
                        border.color: Theme.statusBarAccentColor
                        clip: true

                        Image {
                            anchors {
                                fill: parent
                                bottomMargin: 30
                            }
                            source: wallpaperCard.fileUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            smooth: true
                            mipmap: true
                        }

                        Rectangle {
                            anchors {
                                right: parent.right
                                bottom: parent.bottom
                                left: parent.left
                            }
                            height: 30
                            color: Theme.statusBarWorkspaceColor

                            Text {
                                anchors {
                                    fill: parent
                                    rightMargin: 9
                                    leftMargin: 9
                                }
                                text: wallpaperCard.fileName
                                verticalAlignment: Text.AlignVCenter
                                color: Theme.statusBarTextColor
                                font.family: "Poppins"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                elide: Text.ElideMiddle
                            }
                        }

                        Rectangle {
                            visible: root.selectedSource.toString() === wallpaperCard.fileUrl.toString()
                            anchors {
                                top: parent.top
                                right: parent.right
                                margins: 9
                            }
                            width: 25
                            height: 25
                            radius: 9
                            color: Theme.statusBarAccentColor

                            Text {
                                anchors.centerIn: parent
                                text: "󰄬"
                                color: Theme.statusBarBackgroundColor
                                font.family: "JetBrains Mono Nerd Font"
                                font.pixelSize: 13
                            }
                        }

                        HoverHandler {
                            id: cardHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler { onTapped: root.selectedSource = wallpaperCard.fileUrl }
                    }
                }
            }

            Column {
                visible: wallpaperModel.status === FolderListModel.Ready
                    && wallpaperModel.count === 0
                anchors.centerIn: parent
                spacing: 8

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰉏"
                    color: Theme.statusBarMutedColor
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 34
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No wallpapers found"
                    color: Theme.statusBarTextColor
                    font.family: "Poppins"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Add images to ~/Pictures/Wallpapers"
                    color: Theme.statusBarMutedColor
                    font.family: "Poppins"
                    font.pixelSize: 11
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: root.hasPendingSelection
                    ? "Ready to apply selected wallpaper"
                    : "Current wallpaper selected"
                color: root.hasPendingSelection
                    ? Theme.statusBarAccentColor
                    : Theme.statusBarMutedColor
                font.family: "Poppins"
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }

            Rectangle {
                Layout.preferredWidth: 108
                Layout.preferredHeight: 42
                radius: 13
                color: root.hasPendingSelection
                    ? applyHover.hovered
                        ? Theme.statusBarHighlightColor
                        : Theme.statusBarAccentColor
                    : Theme.statusBarSurfaceBorderColor

                Text {
                    anchors.centerIn: parent
                    text: "Apply"
                    color: root.hasPendingSelection
                        ? Theme.statusBarBackgroundColor
                        : Theme.statusBarMutedColor
                    font.family: "Poppins"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

                HoverHandler {
                    id: applyHover
                    enabled: root.hasPendingSelection
                    cursorShape: root.hasPendingSelection
                        ? Qt.PointingHandCursor
                        : Qt.ArrowCursor
                }
                TapHandler {
                    enabled: root.hasPendingSelection
                    onTapped: WallpaperService.setWallpaper(root.selectedSource)
                }
            }
        }
    }
}
