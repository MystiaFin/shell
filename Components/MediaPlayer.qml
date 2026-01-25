import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    height: 100
    implicitWidth: 400

    property string title: ""
    property string artist: ""
    property string artUrl: ""
    property string status: "Stopped"
    property real position: 0
    property real length: 0
    property var onPlayPause: null
    property var onNext: null
    property var onPrevious: null
    property var cavaBars: []

    function formatTime(seconds) {
        var mins = Math.floor(seconds / 60);
        var secs = Math.floor(seconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    Rectangle {
        anchors.fill: parent
        color: "#313244"
        radius: 12

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Rectangle {
                Layout.preferredWidth: 68
                Layout.preferredHeight: 68
                Layout.alignment: Qt.AlignVCenter
                radius: 6
                color: "#45475a"

                Image {
                    anchors.fill: parent
                    anchors.margins: 0
                    source: root.artUrl
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    visible: root.artUrl !== ""
                    clip: true
                }

                Text {
                    visible: root.artUrl === ""
                    anchors.centerIn: parent
                    text: "󰝚"
                    font.pixelSize: 32
                    color: "#6c7086"
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.title || "No media playing"
                    font.pixelSize: 15
                    font.bold: true
                    color: "#cdd6f4"
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root.artist || ""
                    font.pixelSize: 12
                    color: "#a6adc8"
                    elide: Text.ElideRight
                    visible: root.artist !== ""
                }

                Item {
                    Layout.fillHeight: true
                    Layout.minimumHeight: 2
                }

                Row {
                    id: visualizer
                    Layout.fillWidth: true
                    Layout.preferredHeight: 13
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 2
                    spacing: 2

                    Repeater {
                        model: root.cavaBars
                        delegate: Item {
                            width: 8
                            height: 13

                            Rectangle {
                                width: 6
                                height: Math.max(2, modelData * 10)
                                radius: 2
                                color: "#89b4fa"
                                anchors.bottom: parent.bottom

                                Behavior on height {
                                    NumberAnimation {
                                        duration: 50
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Layout.topMargin: 0

                    Text {
                        text: root.formatTime(root.position)
                        font.pixelSize: 10
                        color: "#a6adc8"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 3
                        radius: 1.5
                        color: "#45475a"

                        Rectangle {
                            width: root.length > 0 ? (root.position / root.length) * parent.width : 0
                            height: parent.height
                            radius: 1.5
                            color: "#89b4fa"
                        }
                    }

                    Text {
                        text: root.formatTime(root.length)
                        font.pixelSize: 10
                        color: "#a6adc8"
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 4

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: previousMouse.containsMouse ? "#45475a" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        font.pixelSize: 18
                        color: "#cdd6f4"
                    }

                    MouseArea {
                        id: previousMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.onPrevious)
                                root.onPrevious();
                        }
                    }
                }

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: playPauseMouse.containsMouse ? "#74c7ec" : "#89b4fa"

                    Text {
                        anchors.centerIn: parent
                        text: root.status === "Playing" ? "󰏤" : "󰐊"
                        font.pixelSize: 20
                        color: "#1e1e2e"
                        leftPadding: root.status === "Playing" ? 0 : 2
                    }
                    MouseArea {
                        id: playPauseMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            mediaService.playPause();
                        }
                    }
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: nextMouse.containsMouse ? "#45475a" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        font.pixelSize: 18
                        color: "#cdd6f4"
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.onNext)
                                root.onNext();
                        }
                    }
                }
            }
        }
    }
}
