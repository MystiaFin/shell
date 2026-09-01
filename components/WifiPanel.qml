import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import "../services"

Item {
    id: root

    property string expandedNetwork: ""

    function closePassword(): void {
        expandedNetwork = "";
        UtilityCenterState.passwordEntryActive = false;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            radius: 14
            color: Theme.statusBarSurfaceColor

            RowLayout {
                anchors {
                    fill: parent
                    margins: 10
                }
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 12
                    color: NetworkService.enabled
                        ? Theme.statusBarBlueColor
                        : Theme.statusBarSurfaceBorderColor

                    Text {
                        anchors.centerIn: parent
                        text: "󰖩"
                        color: Theme.statusBarBackgroundColor
                        font.family: "JetBrains Mono Nerd Font"
                        font.pixelSize: 18
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        text: NetworkService.enabled ? "Wi-Fi" : "Wi-Fi off"
                        color: Theme.statusBarTextColor
                        font.family: "Poppins"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: NetworkService.connectedNetwork
                            ? NetworkService.connectedNetwork.name
                            : NetworkService.scanning ? "Scanning…" : "Not connected"
                        color: NetworkService.connectedNetwork
                            ? Theme.statusBarGreenColor
                            : Theme.statusBarMutedColor
                        font.family: "Poppins"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }
                }

                UtilitySwitch {
                    checked: NetworkService.enabled
                    onToggled: NetworkService.toggleWifi()
                }
            }
        }

        ListView {
            id: networkList

            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: NetworkService.enabled && NetworkService.wifiDevice !== null
            model: NetworkService.networks
            spacing: 7
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: networkCard

                required property var modelData

                width: networkList.width
                height: root.expandedNetwork === modelData.name && !modelData.connected ? 104 : 50
                radius: 12
                color: modelData.connected
                    ? Theme.statusBarWorkspaceColor
                    : Theme.statusBarSurfaceColor
                clip: true

                Behavior on height {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
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
                            text: modelData.signalStrength > 0.75 ? "󰤨"
                                : modelData.signalStrength > 0.5 ? "󰤥"
                                : modelData.signalStrength > 0.25 ? "󰤢" : "󰤟"
                            color: Theme.statusBarBlueColor
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 17
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: Theme.statusBarTextColor
                                font.family: "Poppins"
                                font.pixelSize: 12
                                font.weight: modelData.connected ? Font.DemiBold : Font.Normal
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.connected ? "Connected"
                                    : modelData.stateChanging ? "Connecting…"
                                    : modelData.known ? "Saved" : "Available"
                                color: modelData.connected
                                    ? Theme.statusBarGreenColor
                                    : Theme.statusBarMutedColor
                                font.family: "Poppins"
                                font.pixelSize: 9
                            }
                        }

                        Text {
                            text: modelData.connected ? "󰅖" : modelData.known ? "󰄬" : "󰌾"
                            color: modelData.connected
                                ? Theme.statusBarRedColor
                                : Theme.statusBarMutedColor
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 14
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        visible: root.expandedNetwork === modelData.name && !modelData.connected
                        spacing: 7

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            radius: 9
                            color: Theme.statusBarWorkspaceColor
                            border.width: 1
                            border.color: passwordInput.activeFocus
                                ? Theme.statusBarBlueColor
                                : Theme.statusBarSurfaceBorderColor

                            TextInput {
                                id: passwordInput
                                anchors {
                                    fill: parent
                                    leftMargin: 10
                                    rightMargin: 40
                                }
                                verticalAlignment: TextInput.AlignVCenter
                                color: Theme.statusBarTextColor
                                font.family: "Poppins"
                                font.pixelSize: 11
                                echoMode: revealPassword.show ? TextInput.Normal : TextInput.Password
                                passwordCharacter: "•"
                                onAccepted: {
                                    modelData.connectWithPsk(text);
                                    root.closePassword();
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
                                text: show ? "󰈈" : "󰈉"
                                color: Theme.statusBarMutedColor
                                font.family: "JetBrains Mono Nerd Font"
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
                                ? Theme.statusBarSurfaceBorderColor
                                : Theme.statusBarWorkspaceColor

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: Theme.statusBarRedColor
                                font.family: "JetBrains Mono Nerd Font"
                                font.pixelSize: 14
                            }

                            HoverHandler {
                                id: cancelHover
                                cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler { onTapped: root.closePassword() }
                        }

                        Rectangle {
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            radius: 9
                            color: connectHover.hovered
                                ? Theme.statusBarGreenColor
                                : Theme.statusBarWorkspaceColor

                            Text {
                                anchors.centerIn: parent
                                text: "󰄬"
                                color: connectHover.hovered
                                    ? Theme.statusBarBackgroundColor
                                    : Theme.statusBarGreenColor
                                font.family: "JetBrains Mono Nerd Font"
                                font.pixelSize: 14
                            }

                            HoverHandler {
                                id: connectHover
                                cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler {
                                onTapped: {
                                    modelData.connectWithPsk(passwordInput.text);
                                    root.closePassword();
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
                        if (networkCard.modelData.connected) {
                            networkCard.modelData.disconnect();
                        } else if (networkCard.modelData.known
                                || networkCard.modelData.security === WifiSecurityType.None) {
                            networkCard.modelData.connect();
                            root.closePassword();
                        } else {
                            root.expandedNetwork = networkCard.modelData.name;
                            UtilityCenterState.passwordEntryActive = true;
                        }
                    }
                }

                Connections {
                    target: networkCard.modelData
                    function onConnectionFailed(reason) {
                        root.expandedNetwork = networkCard.modelData.name;
                        UtilityCenterState.passwordEntryActive = true;
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: NetworkService.networks.length === 0
                text: NetworkService.scanning ? "Scanning…" : "No networks found"
                color: Theme.statusBarMutedColor
                font.family: "Poppins"
                font.pixelSize: 12
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            visible: !NetworkService.hardwareEnabled
            text: "Wi-Fi is disabled by hardware"
            color: Theme.statusBarRedColor
            font.family: "Poppins"
            font.pixelSize: 11
        }
    }
}
