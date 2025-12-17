import QtQuick
import "../Services"
import "../Anim"

Item {
    id: root
    width: childrenRect.width
    height: 26

    property color surfaceColor: "#313244"
    property color textColor: "#cdd6f4"
    
    MprisService {
        id: mprisService
    }

    // Fallback when no media
    Item {
        visible: !mprisService.hasPlayers
        height: 26
        width: fallbackRect.width

        Rectangle {
            id: fallbackRect
            height: 26
            width: fallbackRow.width + 20
            color: root.surfaceColor
            radius: 13
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 13
            color: root.surfaceColor
        }

        Row {
            id: fallbackRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "󰎈"
                color: "#a6e3a1"
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "- No media"
                color: root.textColor
                font.pixelSize: 13
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Active media player
    Item {
        visible: mprisService.hasPlayers && mprisService.activePlayer
        height: 26
        width: mediaRect.width

        Rectangle {
            id: mediaRect
            height: 26
            width: mediaRow.width + 20
            color: root.surfaceColor
            radius: 13
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 13
            color: root.surfaceColor
        }

        Row {
            id: mediaRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "󰎈"
                color: "#a6e3a1"
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: scrollText.isLong ? 250 : scrollText.implicitWidth
                height: 26
                clip: true
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: scrollText
                    property bool isLong: mprisService.fullText.length > 32

                    text: isLong ? mprisService.fullText + " •  " + mprisService.fullText : mprisService.fullText
                    color: root.textColor
                    font.pixelSize: 13
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter

                    MprisAnim {
                        id: scrollAnimation
                        textTarget: scrollText
                        fullText: mprisService.fullText
                    }

                    Connections {
                        target: mprisService
                        function onFullTextChanged() {
                            if (scrollText.isLong) {
                                scrollAnimation.restart();
                            } else {
                                scrollAnimation.stop();
                                scrollText.x = 0;
                            }
                        }
                    }

                    Component.onCompleted: {
                        if (isLong) {
                            scrollAnimation.start();
                        }
                    }
                }
            }
        }
    }
}
