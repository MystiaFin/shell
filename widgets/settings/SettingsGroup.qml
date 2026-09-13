import QtQuick
import "../../components/theme"

Rectangle {
    id: root
    default property alias content: groupContent.data

    width: parent ? parent.width : 0
    height: groupContent.implicitHeight

    // Raise the entire group while one of its choice rows has an open menu,
    // so the floating dropdown is painted above following groups as well.
    readonly property bool hasExpandedMenu: {
        for (let i = 0; i < groupContent.children.length; i++) {
            const child = groupContent.children[i];
            if (child && child.expanded === true)
                return true;
        }
        return false;
    }
    z: hasExpandedMenu ? 50 : 0
    radius: ShellMetrics.radiusExtraLarge
    color: Theme.panelSurfaceColor
    clip: false

    Column {
        id: groupContent
        width: parent.width
    }
}
