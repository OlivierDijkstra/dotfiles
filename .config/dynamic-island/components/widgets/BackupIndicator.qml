import QtQuick
import ".." as Theme

// Hidden while backups are healthy; a pulsing glyph while running, red on alert.
Item {
    id: root

    required property var backupState
    readonly property bool running: !!backupState && backupState.running
    readonly property bool alert: !!backupState && backupState.alert

    visible: running || alert
    implicitWidth: 14
    implicitHeight: 14

    Theme.ThemedIcon {
        anchors.fill: parent
        source: root.running ? "../../assets/icons/lucide/hard-drive-upload.svg" : "../../assets/icons/lucide/hard-drive.svg"
        sourceSize.width: width
        sourceSize.height: height
        color: root.alert ? Theme.Palette.danger : Theme.Palette.mutedForeground

        SequentialAnimation on opacity {
            running: root.visible && root.running
            loops: Animation.Infinite
            alwaysRunToEnd: true

            NumberAnimation {
                to: 0.35
                duration: 900
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                to: 1
                duration: 900
                easing.type: Easing.InOutSine
            }
        }
    }
}
