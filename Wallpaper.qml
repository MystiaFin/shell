import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Qt.labs.folderlistmodel 2.15

PanelWindow {
    id: root
    
    property var modelData
    property var screen: modelData 
    required property color bgColor
    
    WlrLayershell.namespace: "wallpaper"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrLayershell.None
    
    anchors { 
        top: true
        bottom: true
        left: true
        right: true
    }
    
    color: "transparent"

    property int cornerRadius: 16
    property string wallpaperFolder: "Wallpapers"

    FolderListModel {
        id: wpModel
        folder: Qt.resolvedUrl(root.wallpaperFolder)
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false
        sortField: FolderListModel.Name
    }

    Rectangle {
        anchors.fill: parent
        color: root.bgColor
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: 40

        Image {
            id: srcImage
            anchors.fill: parent
            visible: false
            fillMode: Image.PreserveAspectCrop
            source: wpModel.count > 0 ? wpModel.get(0, "fileUrl") : ""
        }

        Item {
            id: maskItem
            anchors.fill: parent
            visible: false
            layer.enabled: true
            Rectangle {
                anchors.fill: parent
                radius: root.cornerRadius
                color: "black"
            }
        }

        MultiEffect {
            anchors.fill: parent
            source: srcImage
            maskEnabled: true
            maskSource: maskItem
        }
    }
}
