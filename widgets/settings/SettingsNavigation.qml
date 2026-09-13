import QtQuick
import "../../components/common"
import "../../components/theme"

Rectangle {
    id: root

    required property string currentSection
    signal sectionRequested(string section)

    readonly property var mainItems: [
        { key: "appearance", label: "Appearance", icon: "󰍹" },
        { key: "colors", label: "Colors", icon: Icons.colorScheme },
        { key: "launcher", label: "Launcher", icon: "󰍉" },
        { key: "wallpaper", label: "Wallpaper", icon: Icons.wallpaper },
        { key: "bar", label: "Status bar", icon: "󰍜" },
        { key: "behavior", label: "Behavior", icon: "󰒓" },
        { key: "widgets", label: "Floating widgets", icon: "󰖲" },
        { key: "animations", label: "Animations", icon: "󰔎" },
        { key: "integrations", label: "Integrations", icon: "󰌹" }
    ]
    readonly property int currentIndex: mainItems.findIndex(
        item => item.key === currentSection)
    readonly property real itemHeight: 58
    readonly property real itemSpacing: 3
    readonly property real selectionY: currentSection === "about"
        ? aboutItem.y
        : 12 + Math.max(0, currentIndex) * (itemHeight + itemSpacing)

    radius: ShellMetrics.radiusExtraLarge
    color: Theme.panelSurfaceColor
    clip: true

    Rectangle {
        id: selectionHighlight
        x: 10
        y: root.selectionY
        width: root.width - 20
        height: root.itemHeight
        radius: ShellMetrics.radiusMedium
        color: Theme.selectedSurfaceColor
        opacity: root.currentIndex >= 0 || root.currentSection === "about" ? 1 : 0

        Behavior on y {
            MotionAnimation { type: MotionAnimation.FastSpatial }
        }
    }

    Column {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 12
            leftMargin: 10
            rightMargin: 10
        }
        spacing: root.itemSpacing

        Repeater {
            model: root.mainItems

            delegate: Item {
                id: navItem

                required property var modelData
                width: parent.width
                height: root.itemHeight

                Rectangle {
                    anchors.fill: parent
                    radius: ShellMetrics.radiusMedium
                    color: Theme.hoverSurfaceColor
                    opacity: navHover.hovered
                        && root.currentSection !== navItem.modelData.key ? 1 : 0
                }

                Item {
                    id: iconSlot
                    anchors {
                        left: parent.left
                        leftMargin: 13
                        verticalCenter: parent.verticalCenter
                    }
                    width: 26
                    height: 26

                    Text {
                        anchors.fill: parent
                        text: navItem.modelData.icon
                        color: root.currentSection === navItem.modelData.key
                            ? Theme.accentColor : Theme.secondaryTextColor
                        font.family: Typography.nerdIconFontFamily
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    anchors {
                        left: iconSlot.right
                        right: parent.right
                        leftMargin: 12
                        rightMargin: 13
                        verticalCenter: parent.verticalCenter
                    }
                    text: navItem.modelData.label
                    color: root.currentSection === navItem.modelData.key
                        ? Theme.primaryTextColor : Theme.secondaryTextColor
                    font.family: Typography.bodyFontFamily
                    font.pixelSize: 13
                    font.weight: root.currentSection === navItem.modelData.key
                        ? Font.DemiBold : Font.Normal
                    elide: Text.ElideRight
                }

                HoverHandler {
                    id: navHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: root.sectionRequested(navItem.modelData.key)
                }
            }
        }
    }

    Item {
        id: aboutItem

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 10
            rightMargin: 10
            bottomMargin: 12
        }
        height: root.itemHeight

        Rectangle {
            anchors.fill: parent
            radius: ShellMetrics.radiusMedium
            color: Theme.hoverSurfaceColor
            opacity: aboutHover.hovered && root.currentSection !== "about" ? 1 : 0
        }

        Item {
            id: aboutIconSlot
            anchors {
                left: parent.left
                leftMargin: 13
                verticalCenter: parent.verticalCenter
            }
            width: 26
            height: 26

            Text {
                anchors.fill: parent
                text: "󰋼"
                color: root.currentSection === "about"
                    ? Theme.accentColor : Theme.secondaryTextColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Text {
            anchors {
                left: aboutIconSlot.right
                right: parent.right
                leftMargin: 12
                rightMargin: 13
                verticalCenter: parent.verticalCenter
            }
            text: "About"
            color: root.currentSection === "about"
                ? Theme.primaryTextColor : Theme.secondaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 13
            font.weight: root.currentSection === "about"
                ? Font.DemiBold : Font.Normal
        }

        HoverHandler {
            id: aboutHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler { onTapped: root.sectionRequested("about") }
    }
}
