pragma Singleton
import QtQuick

QtObject {
    id: root
    property var current: new Date()

    property Timer ticker: Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.current = new Date()
    }
}
