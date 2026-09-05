import QtQuick
import ".." as Theme

Item {
    id: root

    required property var recordingState
    readonly property bool recording: !!recordingState && recordingState.recording
    readonly property bool hovered: hoverHandler.hovered
    readonly property int bridgeWidth: 6

    implicitWidth: bridgeWidth + content.implicitWidth + 20
    implicitHeight: 36
    width: implicitWidth
    height: implicitHeight
    opacity: recording ? 1 : 0
    visible: opacity > 0
    enabled: recording

    Behavior on opacity {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    // The transparent bridge keeps hover continuous between island and badge.
    HoverHandler {
        id: hoverHandler
        target: null
    }

    Rectangle {
        id: button

        x: root.bridgeWidth
        width: parent.width - x
        height: parent.height
        radius: height / 2
        color: Theme.Palette.islandBackground
        border.width: 1
        border.color: stopArea.containsMouse ? Theme.Palette.danger : Theme.Palette.border
        scale: stopArea.pressed ? 0.96 : 1

        Accessible.role: Accessible.Button
        Accessible.name: "Stop screen recording"
        Accessible.description: root.recordingState ? root.recordingState.elapsedText : ""
        Accessible.onPressAction: root.recordingState.stopRecording()

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Row {
            id: content

            anchors.centerIn: parent
            spacing: 7

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 8
                height: 8
                radius: stopArea.containsMouse ? 1 : 4
                color: Theme.Palette.danger
            }

            Text {
                text: root.recordingState ? root.recordingState.elapsedText : "0:00"
                color: Theme.Palette.danger
                font.family: "Geist Mono"
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: stopArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.recordingState.stopRecording()
        }
    }
}
