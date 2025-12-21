import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../Anim"

Rectangle {
    id: notifRect

    // Catppuccin Mocha Colors
    readonly property color baseColor: "#1e1e2e"
    readonly property color textColor: "#cdd6f4"
    readonly property color subtextColor: "#a6adc8"
    readonly property color blueColor: "#89b4fa"

    width: ListView.view.width - 30
    height: 90
    color: baseColor
    radius: 12

    // --- NEW: Blue Border ---
    border.width: 2
    border.color: blueColor

    // Shadow Effect
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        color: "#8011111b"
        radius: 16
        samples: 24
        verticalOffset: 4
    }

    // The transform object that the animation will manipulate
    transform: Translate {
        id: slideTransform
    }

    // --- ANIMATION COMPONENT ---
    NotificationAnim {
        id: animLogic
        targetTransform: slideTransform
        targetModel: model 
        targetIndex: index
        autoHideDuration: 6000
    }

    // Layout for Icon + Text
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Icon Container
        Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            color: "transparent"

            Image {
                anchors.fill: parent
                source: model.icon
                fillMode: Image.PreserveAspectFit
                sourceSize.width: 48
                sourceSize.height: 48
                onStatusChanged: {
                    if (status === Image.Error)
                        visible = false;
                }
            }
        }

        // Text Column
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4 // Increased spacing slightly to accommodate the line

            Text {
                text: model.summary
                color: textColor
                font.pixelSize: 18
                font.family: "Poppins"
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: model.body
                color: subtextColor
                font.family: "Poppins"
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.fillHeight: true
                elide: Text.ElideRight
                maximumLineCount: 2
            }
        }
    }
}
