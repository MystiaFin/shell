import Quickshell
import QtQuick
import "../Components"
import "../Services" as Services

PanelWindow {
    id: panel
    property var modelData
    property var bgColor
    property bool visible: false

    screen: modelData
    exclusionMode: ExclusionMode.Ignore

    // 1. Initialize Services
    Services.WifiService {
        id: wifiService
    }
    
    Services.BluetoothService {
        id: bluetoothService
    }

    anchors {
        right: true
        top: true
        bottom: true
    }

    margins {
        top: 40
        right: visible ? 0 : -459

        Behavior on right {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
    }

    implicitWidth: 460
    color: "transparent"

    // Notification Service
    Services.NotificationService {
        id: notificationService
    }

    Rectangle {
        id: mainRect
        anchors.fill: parent
        anchors.margins: 4
        color: panel.bgColor
        radius: 18

        property string currentView: "notifications"

        // Top Section - Buttons
        Row {
            id: topButtons
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 16
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            IconButton {
                icon: "󰂚"
                buttonColor: "#89b4fa"
                active: mainRect.currentView === "notifications"
                onClicked: {
                    mainRect.currentView = "notifications";
                }
            }

            IconButton {
                icon: "󰖩"
                buttonColor: "#89b4fa"
                active: mainRect.currentView === "wifi"
                onClicked: {
                    mainRect.currentView = "wifi";
                }
            }

            IconButton {
                icon: "󰂯"
                buttonColor: "#89b4fa"
                active: mainRect.currentView === "bluetooth"
                onClicked: {
                    mainRect.currentView = "bluetooth";
                }
            }
        }

        // Bottom Section - Calendar
        Rectangle {
            id: calendarWidget
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: 16
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            height: 300
            color: "#313244"
            radius: 12

            Text {
                anchors.centerIn: parent
                text: "Calendar Widget"
                color: "#cdd6f4"
                font.pixelSize: 16
            }
        }

        // Middle Section Container
        Item {
            id: middleContainer
            anchors.top: topButtons.bottom
            anchors.bottom: calendarWidget.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 16
            anchors.bottomMargin: 16
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            // Notifications Widget
            NotificationPanelComponent {
                id: notificationSection
                anchors.fill: parent
                notificationModel: notificationService.notificationModel
                opacity: mainRect.currentView === "notifications" ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            // WiFi Widget
            WifiComponent {
                id: wifiSection
                anchors.fill: parent
                wifiService: wifiService
                opacity: mainRect.currentView === "wifi" ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            // Bluetooth Widget - REPLACED PLACEHOLDER
            BluetoothComponent {
                id: bluetoothSection
                anchors.fill: parent
                btService: bluetoothService
                opacity: mainRect.currentView === "bluetooth" ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
