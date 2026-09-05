import QtQuick
import ".." as Theme

Item {
    id: root

    required property var recordingState
    readonly property bool recording: !!recordingState && recordingState.recording

    implicitWidth: content.implicitWidth + 8
    implicitHeight: 20
    width: implicitWidth
    height: implicitHeight
    visible: recording
    enabled: recording
    scale: stopArea.pressed ? 0.96 : 1

    Accessible.role: Accessible.Button
    Accessible.name: "Stop screen recording"
    Accessible.description: recordingState ? recordingState.elapsedText : ""
    Accessible.onPressAction: recordingState.stopRecording()

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    Row {
        id: content

        anchors.centerIn: parent
        spacing: 6

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 7
            height: 7
            radius: stopArea.containsMouse ? 1 : 3.5
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
        anchors.topMargin: -6
        anchors.bottomMargin: -6
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.recordingState.stopRecording()
    }
}
