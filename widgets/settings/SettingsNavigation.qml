import QtQuick
import "../../components/common"
import "../../components/theme"

Rectangle {
    id: root

    required property string currentSection
    signal sectionRequested(string section)

    readonly property int currentIndex: currentSection === "animations" ? 0 : currentSection === "integrations" ? 1 : currentSection === "widgets" ? 2 : -1

    radius: ShellMetrics.radiusExtraLarge
    color: Theme.panelSurfaceColor

    Rectangle {
        id: selectionHighlight

        x: 10
        y: 10 + Math.max(0, root.currentIndex) * 52
        width: root.width - 20
        height: 48
        radius: ShellMetrics.radiusMedium
        color: Theme.selectedSurfaceColor
        opacity: root.currentIndex >= 0 ? 1 : 0

        Behavior on y {
            MotionAnimation {
                type: MotionAnimation.FastSpatial
            }
        }
    }

    Column {
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 4

        Repeater {
            model: [
                {
                    key: "animations",
                    label: "Animations",
                    icon: "󰔎"
                },
                {
                    key: "integrations",
                    label: "Color integrations",
                    icon: Icons.colorScheme
                },
                {
                    key: "widgets",
                    label: "Floating widgets",
                    icon: "󰖲"
                }
            ]

            delegate: Item {
                id: navItem

                required property var modelData

                width: parent.width
                height: 48

                Rectangle {
                    anchors.fill: parent
                    radius: ShellMetrics.radiusMedium
                    color: Theme.hoverSurfaceColor

                    opacity: navHover.hovered && root.currentSection !== navItem.modelData.key ? 1 : 0

                    Behavior on opacity {
                        MotionAnimation {
                            type: MotionAnimation.FastEffects
                        }
                    }
                }
                Row {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 13
                        rightMargin: 13
                    }
                    spacing: 12

                    Text {
                        width: 22
                        text: navItem.modelData.icon
                        color: root.currentSection === navItem.modelData.key ? Theme.accentColor : Theme.secondaryTextColor
                        font.family: Typography.nerdIconFontFamily
                        font.pixelSize: 17
                        horizontalAlignment: Text.AlignHCenter

                        Behavior on color {
                            MotionColorAnimation {
                                type: MotionAnimation.FastEffects
                            }
                        }
                    }

                    Text {
                        width: parent.width - 34
                        text: navItem.modelData.label
                        color: root.currentSection === navItem.modelData.key ? Theme.primaryTextColor : Theme.secondaryTextColor
                        font.family: Typography.bodyFontFamily
                        font.pixelSize: 12
                        font.weight: root.currentSection === navItem.modelData.key ? Font.DemiBold : Font.Normal
                        elide: Text.ElideRight
                    }
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
}
