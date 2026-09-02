import QtQuick
import QtQuick.Layouts
import "../../components/theme"
import "../../services"

Item {
    id: root

    property string expandedNetwork: ""
    readonly property string connectionStatusText: {
        if (NetworkService.connectedNetwork)
            return NetworkService.connectedNetwork.name;
        return NetworkService.scanning ? "Scanning…" : "Not connected";
    }

    function closePassword(): void {
        expandedNetwork = "";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        ConnectivityHeader {
            icon: Icons.wifi
            title: NetworkService.enabled ? "Wi-Fi" : "Wi-Fi off"
            statusText: root.connectionStatusText
            statusColor: NetworkService.connectedNetwork
                ? Theme.successColor
                : Theme.mutedTextColor
            active: NetworkService.enabled
            onToggleRequested: NetworkService.toggleWifi()
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

            delegate: WifiNetworkCard {
                width: networkList.width
                passwordEditorExpanded: root.expandedNetwork === network.name
                onPasswordEditorRequested: root.expandedNetwork = network.name
                onPasswordEditorClosed: root.closePassword()
            }

            Text {
                anchors.centerIn: parent
                visible: NetworkService.networks.length === 0
                text: NetworkService.scanning ? "Scanning…" : "No networks found"
                color: Theme.mutedTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 12
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            visible: !NetworkService.hardwareEnabled
            text: "Wi-Fi is disabled by hardware"
            color: Theme.dangerColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 11
        }
    }
}
