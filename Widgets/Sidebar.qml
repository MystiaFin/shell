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

    Services.WifiService {
        id: wifiService
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
        right: visible ? 0 : -335
        Behavior on right {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
    }

    implicitWidth: 340
    color: "transparent"

    Rectangle {
        id: mainRect
        anchors.fill: parent
        anchors.margins: 4
        color: panel.bgColor
        radius: 18
        border.width: 2
        border.color: "#313244"

        property string currentView: "notifications"
        readonly property int viewIndex: currentView === "wifi" ? 1 : (currentView === "bluetooth" ? 2 : 0)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Row {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
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

            Item {
                id: middleContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                NotificationPanelComponent {
                    width: parent.width
                    height: parent.height
                    notificationModel: notificationService.notificationModel

                    x: (0 - mainRect.viewIndex) * width
                    Behavior on x {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                WifiComponent {
                    width: parent.width
                    height: parent.height
                    wifiService: wifiService

                    x: (1 - mainRect.viewIndex) * width
                    Behavior on x {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                BluetoothComponent {
                    width: parent.width
                    height: parent.height

                    x: (2 - mainRect.viewIndex) * width
                    Behavior on x {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
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
