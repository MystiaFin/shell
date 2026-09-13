import QtQuick
import "../../components/common"
import "../../components/theme"

Item {
    id: root

    property var model
    property real rowHeight: 60
    property string emptyText: "No results found"

    property int resetGeneration: 0

    signal activated(var result)

    function moveSelection(down: bool): void {
        if (resultList.count === 0)
            return;

        if (down)
            resultList.incrementCurrentIndex();
        else
            resultList.decrementCurrentIndex();

        resultList.positionViewAtIndex(
            resultList.currentIndex,
            ListView.Contain
        );
    }

    function activateCurrent(): void {
        if (!resultList.currentItem)
            return;

        root.activated(
            resultList.currentItem.result
        );
    }

    function resetSelection(): void {
        const generation = ++resetGeneration;

        Qt.callLater(() => {
            if (generation !== resetGeneration)
                return;

            resultList.forceLayout();

            resultList.currentIndex =
                resultList.count > 0
                    ? 0
                    : -1;

            resultList.positionViewAtBeginning();
        });
    }

    ListView {
        id: resultList

        anchors.fill: parent

        model: root.model

        clip: true
        boundsBehavior: Flickable.StopAtBounds
        reuseItems: false

        currentIndex: -1
        keyNavigationWraps: true
        highlightFollowsCurrentItem: false

        remove: Transition {
            MotionAnimation {
                type: MotionAnimation.FastEffects
                property: "opacity"

                from: 1
                to: 0
            }
        }

        highlight: Rectangle {
            width: resultList.width
            height: root.rowHeight

            y: resultList.currentItem
                ? resultList.currentItem.y
                : 0

            radius: ShellMetrics.radiusMedium
            color: Theme.selectedSurfaceColor

            opacity:
                resultList.currentItem ? 1 : 0

            Behavior on y {
                MotionAnimation {
                    type: MotionAnimation.FastSpatial
                }
            }
        }

        onCountChanged: {
            if (count === 0) {
                currentIndex = -1;
                return;
            }

            if (currentIndex < 0)
                currentIndex = 0;
            else if (currentIndex >= count)
                currentIndex = count - 1;
        }

        delegate: LauncherResultDelegate {
            required property var modelData
            required property int index

            width: resultList.width
            height: root.rowHeight

            result: modelData

            selected:
                ListView.isCurrentItem

            onActivated: {
                resultList.currentIndex = index;

                root.activated(
                    modelData
                );
            }
        }
    }

    Text {
        anchors.centerIn: parent

        visible:
            resultList.count === 0

        text: root.emptyText

        color: Theme.secondaryTextColor

        font.family: Typography.bodyFontFamily
        font.pixelSize: 14
    }
}
