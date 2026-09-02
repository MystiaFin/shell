import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import "../../components/theme"

Rectangle {
    id: root

    required property var modelData
    readonly property var network: modelData
    property bool passwordEditorExpanded: false

    readonly property string signalIcon: {
        if (network.signalStrength > 0.75)
            return Icons.wifiStrong;
        if (network.signalStrength > 0.5)
            return Icons.wifiGood;
        if (network.signalStrength > 0.25)
            return Icons.wifiWeak;
        return Icons.wifiNone;
    }
    readonly property string connectionStatusText: {
        if (network.connected)
            return "Connected";
        if (network.stateChanging)
            return "Connecting…";
        return network.known ? "Saved" : "Available";
    }
    readonly property string actionIcon: {
        if (network.connected)
            return Icons.close;
        return network.known ? Icons.confirm : Icons.lock;
    }

    signal passwordEditorRequested()
    signal passwordEditorClosed()

    height: passwordEditorExpanded && !network.connected ? 104 : 50
    radius: 12
    color: network.connected ? Theme.selectedSurfaceColor : Theme.panelSurfaceColor
    clip: true

    Behavior on height {
        NumberAnimation { duration: ShellMetrics.fastAnimationMs; easing.type: Easing.OutCubic }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 9
        }
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 9

            Text {
                text: root.signalIcon
                color: Theme.accentColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 17
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: root.network.name
                    color: Theme.primaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 12
                    font.weight: root.network.connected ? Font.DemiBold : Font.Normal
                    elide: Text.ElideRight
                }

                Text {
                    text: root.connectionStatusText
                    color: root.network.connected ? Theme.successColor : Theme.mutedTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 9
                }
            }

            Text {
                text: root.actionIcon
                color: root.network.connected ? Theme.dangerColor : Theme.mutedTextColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 14
            }
        }

        // Password editor
        RowLayout {
            id: passwordEditor

            Layout.fillWidth: true
            Layout.preferredHeight: 34
            visible: root.passwordEditorExpanded && !root.network.connected
            spacing: 7

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                radius: 9
                color: Theme.selectedSurfaceColor
                border.width: 1
                border.color: passwordInput.activeFocus
                    ? Theme.accentColor
                    : Theme.surfaceBorderColor

                TextInput {
                    id: passwordInput

                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 40
                    }
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.primaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 11
                    echoMode: revealPassword.show ? TextInput.Normal : TextInput.Password
                    passwordCharacter: "•"
                    onAccepted: {
                        root.network.connectWithPsk(text);
                        root.passwordEditorClosed();
                    }
                    onVisibleChanged: if (visible) forceActiveFocus()
                }

                Text {
                    id: revealPassword

                    property bool show: false

                    anchors {
                        right: parent.right
                        rightMargin: 11
                        verticalCenter: parent.verticalCenter
                    }
                    text: show ? Icons.passwordVisible : Icons.passwordHidden
                    color: Theme.mutedTextColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 14

                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: revealPassword.show = !revealPassword.show }
                }
            }

            Rectangle {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                radius: 9
                color: cancelHover.hovered
                    ? Theme.surfaceBorderColor
                    : Theme.selectedSurfaceColor

                Text {
                    anchors.centerIn: parent
                    text: Icons.close
                    color: Theme.dangerColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 14
                }

                HoverHandler {
                    id: cancelHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler { onTapped: root.passwordEditorClosed() }
            }

            Rectangle {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                radius: 9
                color: connectHover.hovered
                    ? Theme.successColor
                    : Theme.selectedSurfaceColor

                Text {
                    anchors.centerIn: parent
                    text: Icons.confirm
                    color: connectHover.hovered
                        ? Theme.shellBackgroundColor
                        : Theme.successColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 14
                }

                HoverHandler {
                    id: connectHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: {
                        root.network.connectWithPsk(passwordInput.text);
                        root.passwordEditorClosed();
                    }
                }
            }
        }
    }

    MouseArea {
        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
        }
        height: 50
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.network.connected) {
                root.network.disconnect();
            } else if (root.network.known
                    || root.network.security === WifiSecurityType.None) {
                root.network.connect();
                root.passwordEditorClosed();
            } else {
                root.passwordEditorRequested();
            }
        }
    }

    Connections {
        target: root.network
        function onConnectionFailed(reason) {
            root.passwordEditorRequested();
        }
    }
}
