import QtQuick
import Quickshell
import QtQml.Models
import "../Services"

ListView {
    id: appList

    property string searchTerm: LauncherService.searchText

    onSearchTermChanged: filterModel.updateFilter()

    model: filterModel

    Connections {
        target: LauncherService
        function onSelectedIndexChanged() {
            if (appList.currentIndex !== LauncherService.selectedIndex) {
                appList.currentIndex = LauncherService.selectedIndex;
            }
        }
    }

    function selectNext() {
        for (var i = currentIndex + 1; i < filterModel.items.count; i++) {
            if (!filterModel.items.get(i).inVisible)
                continue;
            currentIndex = i;
            return;
        }
    }

    function selectPrevious() {
        for (var i = currentIndex - 1; i >= 0; i--) {
            if (!filterModel.items.get(i).inVisible)
                continue;
            currentIndex = i;
            return;
        }
    }
    DelegateModel {
        id: filterModel
        model: LauncherService.applications

        groups: [
            DelegateModelGroup {
                name: "visible"
                includeByDefault: true
            }
        ]

        Component.onCompleted: updateFilter()

        function updateFilter() {
            var search = appList.searchTerm.toLowerCase();
            var firstMatch = -1;

            for (var i = 0; i < items.count; i++) {
                var item = items.get(i);
                var nameVal = (item.model.modelData && item.model.modelData.name) ? item.model.modelData.name : "";
                var match = (search === "" || nameVal.toLowerCase().includes(search));
                item.inVisible = match;
                if (match && firstMatch === -1) {
                    firstMatch = i;
                }
            }
            if (firstMatch !== -1) {
                appList.currentIndex = firstMatch;
                LauncherService.selectedIndex = firstMatch;
            }
        }

        delegate: Item {
            width: appList.width
            readonly property bool inVisible: DelegateModel.inVisible
            visible: DelegateModel.inVisible
            height: visible ? 42 : 0

            property var appData: modelData

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                enabled: parent.visible
                onEntered: appList.currentIndex = index
                onClicked: LauncherService.launchSelected()
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                spacing: 12
                Image {
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter
                    source: modelData.icon ? "image://icon/" + modelData.icon : ""
                }
                Text {
                    text: modelData.name
                    color: "white"
                    font.pixelSize: 14
                    font.family: "Poppins"
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 50
                    elide: Text.ElideRight
                }
            }
        }
    }

    onCurrentIndexChanged: {
        if (currentIndex !== -1 && currentIndex < filterModel.count) {
            LauncherService.selectedIndex = currentIndex;
            positionViewAtIndex(currentIndex, ListView.Contain);

            var item = itemAtIndex(currentIndex);
            if (item && item.visible && item.appData) {
                LauncherService.selectedApp = item.appData;
            }
        }
    }

    highlightMoveDuration: 0
    clip: true
    spacing: 0
    highlight: Rectangle {
        color: "#313244"
        radius: 8
        visible: appList.currentItem ? appList.currentItem.visible : false
    }
}
