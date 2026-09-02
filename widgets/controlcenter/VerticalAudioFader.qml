import QtQuick
import QtQuick.Layouts
import "../../components/theme"

Item {
    id: audioFader

    required property string icon
    required property real value
    property color accentColor: Theme.accentColor
    property bool muted: false
    property bool dragActive: false
    property real displayedValue: value
    signal valueMoved(real value)

    onValueChanged: {
        if (!dragActive)
            displayedValue = value;
    }

    Layout.preferredWidth: 48
    Layout.fillHeight: true

    ColumnLayout {
        anchors {
            fill: parent
            margins: 4
        }
        spacing: 8

        Item {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignHCenter

            Text {
                anchors.centerIn: parent
                text: audioFader.icon
                color: Theme.primaryTextColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 19
            }
        }

        Item {
            id: faderInteractionArea

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 120

            Rectangle {
                id: faderTrack

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                width: 22
                radius: width / 2
                color: Theme.surfaceBorderColor

                Rectangle {
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        left: parent.left
                    }
                    height: Math.min(parent.height, faderHandle.height / 1
                        + audioFader.displayedValue * (parent.height - faderHandle.height))
                    radius: parent.radius
                    color: audioFader.muted
                        ? Theme.mutedTextColor
                        : audioFader.accentColor
                }
            }

            Rectangle {
                id: faderHandle

                anchors.horizontalCenter: parent.horizontalCenter
                y: (1 - audioFader.displayedValue) * (parent.height - height)
                width: 22
                height: 22
                radius: width / 2
                color: Theme.primaryTextColor

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }
            }

            MouseArea {
                id: faderPointerArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: mouseY >= faderHandle.y
                    && mouseY <= faderHandle.y + faderHandle.height
                    ? Qt.PointingHandCursor
                    : Qt.ArrowCursor

                function setValueFromY(pointerY: real): void {
                    const handleRadius = faderHandle.height / 2;
                    const travel = Math.max(1, height - faderHandle.height);
                    const nextValue = 1 - (pointerY - handleRadius) / travel;
                    audioFader.displayedValue = Math.max(0, Math.min(1, nextValue));
                    audioFader.valueMoved(audioFader.displayedValue);
                }

                onPressed: mouse => {
                    audioFader.dragActive = true;
                    setValueFromY(mouse.y);
                }
                onPositionChanged: mouse => {
                    if (pressed)
                        setValueFromY(mouse.y);
                }
                onReleased: {
                    audioFader.dragActive = false;
                    audioFader.displayedValue = audioFader.value;
                }
                onCanceled: {
                    audioFader.dragActive = false;
                    audioFader.displayedValue = audioFader.value;
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Math.round(audioFader.displayedValue * 100) + "%"
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
    }
}
