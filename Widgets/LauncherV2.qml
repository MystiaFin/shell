import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Services"
import "../Anim"
import "../Components"

PanelWindow {
    id: launcher
    signal requestClose

    property bool visible: false

    property int itemHeight: 42
    property int maxItems: 9
    property int searchHeight: 50
    property int spacing: 10
    property int padding: 10 
    property int extraHeight: 10 
    
    property int totalMaxHeight: (maxItems * itemHeight) + searchHeight + spacing + (padding * 2) + extraHeight

    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors.bottom: true

    margins {
        bottom: visible ? 0 : -(totalMaxHeight - 1)
        Behavior on bottom {
            LauncherAnim { duration: 400 }
        }
    }

    implicitWidth: 500
    implicitHeight: totalMaxHeight
    
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    LauncherService {
        id: service
    }

    Item {
        id: mainContainer
        width: parent.width
        
        anchors.bottom: parent.bottom 
        anchors.left: parent.left
        anchors.right: parent.right

        height: (Math.min(service.appModel.count, maxItems) * itemHeight) + searchHeight + spacing + (padding * 2) + extraHeight

        Behavior on height {
            LauncherAnim { duration: 300 }
        }

        Rectangle {
            anchors.fill: parent
            color: "#11111b"
            radius: 16

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.radius
                color: parent.color
            }
        }

        LauncherList {
            id: listComponent
            
            service: service
            rootWindow: launcher
            anchorTarget: searchBar

            itemHeight: launcher.itemHeight
            maxItems: launcher.maxItems
            spacing: launcher.spacing
            padding: launcher.padding
            searchHeight: launcher.searchHeight
            containerHeight: mainContainer.height
        }

        LauncherSearch {
            id: searchBar
            
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: padding
            
            fixedHeight: searchHeight
            padding: launcher.padding
            
            service: service
            rootWindow: launcher
            
            targetList: listComponent.view 
        }
    }

    Timer {
        id: focusKicker
        interval: 10
        repeat: false
        onTriggered: searchBar.input.forceActiveFocus()
    }

    onVisibleChanged: {
        if (visible) {
            focusKicker.restart();
            searchBar.input.text = "";
            service.rebuildList("");
        } else {
            searchBar.input.focus = false;
        }
    }
}
