import Quickshell
import QtQuick
import QtQuick.Layouts
import "../Components"
import "../Services" as Services

PanelWindow {
    id: panel
    property var modelData
    property var bgColor
    property bool visible: false

    screen: modelData
    exclusionMode: ExclusionMode.Ignore
    focusable: true

    // --- Services ---
    Services.WifiService {
        id: wifiService
        typing: passInput.activeFocus
    }
    Services.BluetoothService {
        id: bluetoothService
    }
    Services.BrightnessService {
        id: brightnessService
    }
    Services.NotificationService {
        id: notificationService
    }
    Services.CalendarService {
        id: calendarService
    }

    anchors {
        right: true
        top: true
        bottom: true
    }

    margins {
        top: 40
        right: visible ? 0 : -399
        Behavior on right {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
    }

    implicitWidth: 400
    color: "transparent"

    Rectangle {
        id: mainRect
        anchors.fill: parent
        anchors.margins: 4
        color: panel.bgColor
        radius: 18

        property string currentView: "notifications"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                IconButton {
                    icon: "󰂚"
                    buttonColor: "#89b4fa"
                    active: mainRect.currentView === "notifications"
                    onClicked: mainRect.currentView = "notifications"
                }
                IconButton {
                    icon: "󰖩"
                    buttonColor: "#89b4fa"
                    active: mainRect.currentView === "wifi"
                    onClicked: mainRect.currentView = "wifi"
                }
                IconButton {
                    icon: "󰂯"
                    buttonColor: "#89b4fa"
                    active: mainRect.currentView === "bluetooth"
                    onClicked: mainRect.currentView = "bluetooth"
                }
            }

            BrightnessComponent {
                Layout.fillWidth: true
                service: brightnessService
            }

            // Middle Section
            Item {
                id: middleContainer
                Layout.fillWidth: true
                Layout.fillHeight: true

                NotificationPanelComponent {
                    anchors.fill: parent
                    notificationModel: notificationService.notificationModel
                    opacity: mainRect.currentView === "notifications" ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                        }
                    }
                }

                WifiComponent {
                    anchors.fill: parent
                    wifiService: wifiService
                    opacity: mainRect.currentView === "wifi" ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                        }
                    }
                }

                BluetoothComponent {
                    anchors.fill: parent
                    btService: bluetoothService
                    opacity: mainRect.currentView === "bluetooth" ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                        }
                    }
                }
            }

            CalendarComponent {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                service: calendarService
            }
        }
    }
}
