import QtQuick
import Quickshell
import Quickshell.Wayland
import Qt.labs.folderlistmodel 2.15

PanelWindow {
    id: root
    
    property var modelData
    property var screen: modelData 
    
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
    property string wallpaperFolder: "../Wallpapers"
    
    FolderListModel {
        id: wpModel
        folder: Qt.resolvedUrl(root.wallpaperFolder)
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false
        sortField: FolderListModel.Name
    }
    
    Image {
        anchors.fill: parent
        anchors.topMargin: 40
        fillMode: Image.PreserveAspectCrop
        source: wpModel.count > 0 ? wpModel.get(0, "fileUrl") : ""
    }
}
