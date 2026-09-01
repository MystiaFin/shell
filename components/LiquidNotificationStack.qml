import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../services"

Item {
    id: root

    property real maximumHeight: 600
    readonly property real desiredHeight: NotificationService.popupCount > 0
        ? Math.min(maximumHeight, list.contentHeight + 48)
        : 1

    ListView {
        id: list

        anchors {
            fill: parent
            topMargin: 16
            rightMargin: LiquidMetrics.edgeContentInset
            bottomMargin: 32
            leftMargin: 16
        }
        model: NotificationService.popupModel
        spacing: 8
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        onCountChanged: if (count > 0) positionViewAtEnd()

        remove: Transition {
            NumberAnimation {
                property: "slideOffset"
                from: 0
                to: list.width
                duration: 240
                easing.type: Easing.InCubic
            }
        }

        displaced: Transition {
            NumberAnimation {
                property: "y"
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        delegate: Rectangle {
            id: card

            required property int notificationId
            required property string appName
            required property string summary
            required property string body
            required property string icon
            property real slideOffset: list.width

            width: list.width
            height: Math.max(98, content.implicitHeight + 30)
            radius: 12
            color: Theme.statusBarSurfaceColor
            clip: true
            transform: Translate { x: card.slideOffset }

            Component.onCompleted: enterAnimation.start()

            NumberAnimation {
                id: enterAnimation
                target: card
                property: "slideOffset"
                to: 0
                duration: 240
                easing.type: Easing.OutCubic
            }

            RowLayout {
                id: content

                anchors {
                    fill: parent
                    topMargin: 14
                    rightMargin: 42
                    bottomMargin: 14
                    leftMargin: 14
                }
                spacing: 13

                ClippingRectangle {
                    Layout.preferredWidth: 52
                    Layout.preferredHeight: 52
                    Layout.alignment: Qt.AlignVCenter
                    radius: 16
                    color: Theme.statusBarWorkspaceColor

                    IconImage {
                        anchors.fill: parent
                        anchors.margins: 9
                        source: card.icon
                        visible: card.icon !== ""
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: card.icon === ""
                        text: "󰂚"
                        color: Theme.statusBarAccentColor
                        font.family: "JetBrains Mono Nerd Font"
                        font.pixelSize: 23
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 3

                    Text {
                        Layout.fillWidth: true
                        text: card.appName
                        color: Theme.statusBarAccentColor
                        font.family: "Poppins"
                        font.pixelSize: 9
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.4
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: card.summary
                        color: Theme.statusBarTextColor
                        font.family: "Poppins"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: card.body !== ""
                        text: card.body
                        textFormat: Text.PlainText
                        color: Theme.statusBarMutedColor
                        font.family: "Poppins"
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                }
            }

            Rectangle {
                anchors {
                    top: parent.top
                    right: parent.right
                    topMargin: 10
                    rightMargin: 10
                }
                width: 25
                height: 25
                radius: 9
                color: closeHover.hovered
                    ? Theme.statusBarSurfaceBorderColor
                    : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    color: closeHover.hovered
                        ? Theme.statusBarRedColor
                        : Theme.statusBarMutedColor
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 14
                }

                HoverHandler {
                    id: closeHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: NotificationService.removePopupById(card.notificationId)
                }
            }

            Rectangle {
                id: timeoutLine

                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    bottomMargin: 6
                    leftMargin: 12
                }
                width: parent.width - 24
                height: 3
                radius: height / 2
                color: Theme.statusBarAccentColor

                NumberAnimation on width {
                    from: card.width - 24
                    to: 0
                    duration: 6000
                    easing.type: Easing.Linear
                }
            }

            Timer {
                interval: 6000
                running: true
                onTriggered: NotificationService.removePopupById(card.notificationId)
            }
        }
    }
}
