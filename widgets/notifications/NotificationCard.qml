import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../../components/theme"

Rectangle {
    id: root

    required property int notificationId
    required property string appName
    required property string summary
    required property string body
    required property string iconSource
    required property var receivedAt
    property bool popup: false
    property real slideOffset: popup ? width : 0

    signal closeRequested(int notificationId)

    implicitHeight: Math.max(popup ? 98 : 76,
        content.implicitHeight + (popup ? 30 : 24))
    radius: popup ? 12 : 14
    color: Theme.panelSurfaceColor
    clip: popup
    transform: Translate { x: root.slideOffset }

    Component.onCompleted: {
        if (popup)
            enterAnimation.start();
    }

    NumberAnimation {
        id: enterAnimation
        target: root
        property: "slideOffset"
        to: 0
        duration: 240
        easing.type: Easing.OutCubic
    }

    RowLayout {
        id: content

        anchors {
            fill: parent
            topMargin: root.popup ? 14 : 12
            rightMargin: root.popup ? 42 : 36
            bottomMargin: root.popup ? 14 : 12
            leftMargin: root.popup ? 14 : 12
        }
        spacing: root.popup ? 13 : 10

        ClippingRectangle {
            Layout.preferredWidth: root.popup ? 52 : 38
            Layout.preferredHeight: root.popup ? 52 : 38
            Layout.alignment: root.popup ? Qt.AlignVCenter : Qt.AlignTop
            radius: root.popup ? 16 : 10
            color: Theme.selectedSurfaceColor

            IconImage {
                anchors.fill: parent
                anchors.margins: root.popup ? 9 : 7
                source: root.iconSource
                visible: root.iconSource !== ""
            }

            Text {
                anchors.centerIn: parent
                visible: root.iconSource === ""
                text: Icons.notifications
                color: Theme.accentColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: root.popup ? 23 : 17
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: root.popup ? Qt.AlignVCenter : Qt.AlignTop
            spacing: root.popup ? 3 : 2

            Text {
                Layout.fillWidth: true
                visible: root.popup
                text: root.appName
                color: Theme.accentColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 9
                font.weight: Font.DemiBold
                font.letterSpacing: 0.4
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.summary
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: root.popup ? 14 : 13
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: root.body !== ""
                text: root.body
                textFormat: Text.PlainText
                color: Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 11
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Text {
                visible: !root.popup
                text: root.appName + "  •  " + Qt.formatTime(root.receivedAt, "hh:mm")
                color: Theme.secondaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 9
            }
        }
    }

    Rectangle {
        anchors {
            top: parent.top
            right: parent.right
            topMargin: root.popup ? 10 : 12
            rightMargin: root.popup ? 10 : 12
        }
        width: root.popup ? 25 : 15
        height: root.popup ? 25 : 15
        radius: root.popup ? 9 : 0
        color: root.popup && closeHover.hovered
            ? Theme.surfaceBorderColor
            : Qt.rgba(0, 0, 0, 0)

        Text {
            anchors.centerIn: parent
            text: Icons.close
            color: closeHover.hovered
                ? Theme.dangerColor
                : Theme.mutedTextColor
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: root.popup ? 14 : 15
        }

        HoverHandler {
            id: closeHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: root.closeRequested(root.notificationId)
        }
    }

    Rectangle {
        anchors {
            bottom: parent.bottom
            left: parent.left
            bottomMargin: 6
            leftMargin: 12
        }
        visible: root.popup
        width: parent.width - 24
        height: 3
        radius: height / 2
        color: Theme.accentColor

        NumberAnimation on width {
            running: root.popup
            from: root.width - 24
            to: 0
            duration: ShellMetrics.popupTimeoutMs
            easing.type: Easing.Linear
        }
    }

    Timer {
        interval: ShellMetrics.popupTimeoutMs
        running: root.popup
        onTriggered: root.closeRequested(root.notificationId)
    }
}
