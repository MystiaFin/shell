import QtQuick

Rectangle {
    id: root
    
    // Default color matching your theme, can be overridden
    property color surfaceColor: "#313244"

    height: 26
    width: buttonRow.width + 20
    color: "transparent"

    // Background Pill
    Rectangle {
        anchors.fill: parent
        color: root.surfaceColor
        radius: 13
    }

    // Flat edge on the right (to connect visually with adjacent modules)
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 13
        color: root.surfaceColor
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: sysControls.show = !sysControls.show
    }

    Row {
        id: buttonRow
        anchors.centerIn: parent
        spacing: 6

        // Volume Ring (Blue)
        Item {
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.color: "#45475a"
                border.width: 4
            }

            Canvas {
                id: volumeCanvas
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    var centerX = width / 2;
                    var centerY = height / 2;
                    var lineWidth = 4;
                    var radius = (width / 2) - (lineWidth / 2);

                    var startAngle = -Math.PI / 2;
                    var endAngle = startAngle + (2 * Math.PI * (sysControls.volumeVal / 100));

                    ctx.lineCap = "round";
                    ctx.lineWidth = lineWidth;
                    ctx.strokeStyle = "#89b4fa";

                    ctx.beginPath();
                    ctx.arc(centerX, centerY, radius, startAngle, endAngle, false);
                    ctx.stroke();
                }

                Connections {
                    target: sysControls
                    function onVolumeValChanged() {
                        volumeCanvas.requestPaint();
                    }
                }
            }
        }

        // Microphone Ring (Pink)
        Item {
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.color: "#45475a"
                border.width: 4
            }

            Canvas {
                id: micCanvas
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    var centerX = width / 2;
                    var centerY = height / 2;
                    var lineWidth = 4;
                    var radius = (width / 2) - (lineWidth / 2);

                    var startAngle = -Math.PI / 2;
                    var endAngle = startAngle + (2 * Math.PI * (sysControls.micVal / 100));

                    ctx.lineCap = "round";
                    ctx.lineWidth = lineWidth;
                    ctx.strokeStyle = "#f38ba8";

                    ctx.beginPath();
                    ctx.arc(centerX, centerY, radius, startAngle, endAngle, false);
                    ctx.stroke();
                }

                Connections {
                    target: sysControls
                    function onMicValChanged() {
                        micCanvas.requestPaint();
                    }
                }
            }
        }
    }
}
