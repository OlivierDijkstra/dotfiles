import QtQuick

Item {
    id: root

    property string layoutKey: "volume-pill"
    property bool exclusive: true
    property int surfaceHeight: 36
    property int surfaceRadius: Math.round(surfaceHeight / 2)
    property int leftPadding: 8
    property int rightPadding: 12
    required property var volumeState
    required property var audioRouteState
    property bool available: !!volumeState && volumeState.hasVolumeControl && volumeState.osdVisible
    property int surfaceWidth: Math.ceil(leftPadding + rightPadding + slider.implicitWidth)

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
            anchors.verticalCenter: parent.verticalCenter
            height: 32
            controlSize: 32
            volumeState: root.volumeState
            audioRouteState: root.audioRouteState
        }
    }
}
