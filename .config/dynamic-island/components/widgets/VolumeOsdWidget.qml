import QtQuick

Item {
    id: root
    property var recordingState: null

    property string layoutKey: "volume-pill"
    property bool exclusive: true
    property int surfaceHeight: 36
    property int surfaceRadius: Math.round(surfaceHeight / 2)
    property int leftPadding: 8
    property int rightPadding: 12
    required property var volumeState
    required property var audioRouteState
    property bool available: !!volumeState && volumeState.hasVolumeControl && volumeState.osdVisible
    property int surfaceWidth: Math.ceil(leftPadding + rightPadding + slider.implicitWidth
        + (recordingIndicator.recording ? recordingIndicator.width + 8 : 0))

    visible: false

    onVisibleChanged: {
        if (!visible && volumeState) {
            volumeState.osdHovered = false;
        }
    }

    HoverHandler {
        target: null
        onHoveredChanged: {
            if (root.volumeState) {
                root.volumeState.osdHovered = hovered;
            }
        }
    }

    Item {
        id: contentRow

        anchors.fill: parent
        anchors.leftMargin: root.leftPadding
        anchors.rightMargin: root.rightPadding
        implicitHeight: slider.implicitHeight
        height: implicitHeight

        VolumeWidget {
            id: slider

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: recordingIndicator.recording ? recordingIndicator.width + 8 : 0
            anchors.verticalCenter: parent.verticalCenter
            height: 32
            controlSize: 32
            volumeState: root.volumeState
            audioRouteState: root.audioRouteState
        }

        RecordingIndicator {
            id: recordingIndicator
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            recordingState: root.recordingState
        }
    }
}
