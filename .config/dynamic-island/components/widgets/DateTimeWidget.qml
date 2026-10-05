import QtQuick
import ".." as Theme

Item {
    id: root
    property var recordingState: null

    property string layoutKey: "pill"
    property int verticalPadding: 7
    property int surfaceHeight: Math.ceil(contentRow.implicitHeight + (verticalPadding * 2))
    property int surfaceRadius: Math.round(surfaceHeight / 2)
    property int horizontalPadding: 16
    property int contentSpacing: 8
    property bool available: true
    property date now: new Date()
    property var mediaState: null
    property var keepAwakeState: null
    readonly property var player: mediaState ? mediaState.activePlayer : null
    readonly property bool showMusicIndicator: !!player && player.isPlaying
    property int surfaceWidth: Math.max(156, Math.ceil(contentRow.implicitWidth + (horizontalPadding * 2)))

    visible: false

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Row {
        id: contentRow

        x: Math.round((parent.width - width) / 2)
        y: root.verticalPadding
        spacing: root.contentSpacing

        WorkspaceIndicator {
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: label

            anchors.verticalCenter: parent.verticalCenter
            color: Theme.Palette.foreground
            text: Qt.locale().toString(root.now, "ddd MMM d - HH:mm").toLowerCase()
            font.family: "Geist"
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }

        RecordingIndicator {
            anchors.verticalCenter: parent.verticalCenter
            recordingState: root.recordingState
        }

        KeepAwakeIndicator {
            anchors.verticalCenter: parent.verticalCenter
            keepAwakeState: root.keepAwakeState
        }

        Item {
            id: indicatorFrame

            anchors.verticalCenter: parent.verticalCenter
            width: root.showMusicIndicator ? musicIndicator.implicitWidth : 0
            height: musicIndicator.implicitHeight
            clip: true

            MusicIndicator {
                id: musicIndicator

                anchors.centerIn: parent
                playing: root.showMusicIndicator
                barWidth: 3
                barSpacing: 2
                minimumBarHeight: 5
                maximumBarHeight: 14
            }
        }
    }
}
