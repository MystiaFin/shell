import QtQuick

Rectangle {
    id: root

    property var service
    property var rootWindow
    property var targetList

    property int fixedHeight
    property int padding

    property alias input: searchInput

    height: fixedHeight
    color: "#1e1e2e"
    radius: 12

    TextInput {
        id: searchInput
        anchors.fill: parent
        anchors.margins: 15
        color: "#cdd6f4"
        font.pixelSize: 16
        verticalAlignment: Text.AlignVCenter
        activeFocusOnTab: true

        onTextChanged: service.rebuildList(text)

        Keys.onEscapePressed: rootWindow.requestClose()
        Keys.onDownPressed: targetList.incrementCurrentIndex()
        Keys.onUpPressed: targetList.decrementCurrentIndex()
        Keys.onReturnPressed: {
            if (service.appModel.count > 0) {
                var appID = service.appModel.get(targetList.currentIndex).id;
                service.runner.command = ["sh", "-c", "gtk-launch " + appID + " > /dev/null 2>&1 &"];
                service.runner.running = true;
                rootWindow.requestClose();
            }
        }
    }
}
