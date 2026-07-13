import QtQuick
import Quickshell.Hyprland
import ".." as Theme

Item {
    id: root

    readonly property var displayWorkspaces: {
        const monitor = Hyprland.focusedMonitor
        const values = Hyprland.workspaces.values || []
        const filtered = []

        for (let index = 0; index < values.length; index += 1) {
            const workspace = values[index]

            if (!workspace || workspace.id <= 0) {
                continue
            }

            if (monitor && workspace.monitor && workspace.monitor !== monitor) {
                continue
            }

            filtered.push(workspace)
        }

        filtered.sort((left, right) => left.id - right.id)
        return filtered
    }

    readonly property int workspaceCount: displayWorkspaces.length
    readonly property bool shown: workspaceCount > 1

    implicitWidth: shown ? dots.implicitWidth : 0
    implicitHeight: shown ? dots.implicitHeight : 0
    visible: shown

    Row {
        id: dots

        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: root.displayWorkspaces

            Rectangle {
                required property var modelData

                readonly property var workspace: modelData
                readonly property bool current: !!workspace && (workspace.focused || workspace.active)

                width: current ? 12 : 5
                height: 5
                radius: Math.round(height / 2)
                color: Theme.Palette.foreground
                opacity: current ? 1 : 0.28

                Behavior on width {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.InOutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
