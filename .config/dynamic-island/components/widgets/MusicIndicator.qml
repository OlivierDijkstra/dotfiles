pragma ComponentBehavior: Bound
import QtQuick
import "../Palette.js" as Palette

Item {
    id: root

    property bool playing: false
    property color color: Palette.trackFill
    property int barCount: 4
    property real barWidth: 3
    property real barSpacing: 3
    property real minimumBarHeight: 4
    property real maximumBarHeight: 16
    property real radius: Math.min(barWidth / 2, minimumBarHeight / 2)
    property real hiddenScale: 0.82
    readonly property var frames: [
        [0.42, 0.85, 0.58, 0.94],
        [0.74, 0.52, 0.92, 0.44],
        [0.34, 0.96, 0.46, 0.78],
        [0.88, 0.38, 0.72, 0.54],
        [0.5, 0.76, 0.36, 0.98]
    ]
    property int frameIndex: 0

    implicitWidth: (barCount * barWidth) + (Math.max(0, barCount - 1) * barSpacing)
    implicitHeight: maximumBarHeight
    width: implicitWidth
    height: implicitHeight

    function normalizedBarHeight(index) {
        if (frameIndex < 0 || frameIndex >= frames.length) {
            return 0.6
        }

        const frame = frames[frameIndex]

        if (!frame || index < 0 || index >= frame.length) {
            return 0.6
        }

        return frame[index]
    }

    onPlayingChanged: {
        if (!playing) {
            frameIndex = 0
        }
    }

    Timer {
        interval: 150
        repeat: true
        running: root.playing && root.visible
        onTriggered: root.frameIndex = (root.frameIndex + 1) % root.frames.length
    }

    Row {
        id: indicatorContent

        anchors.fill: parent
        spacing: root.barSpacing
        opacity: root.playing ? 1 : 0
        scale: root.playing ? 1 : root.hiddenScale

        Behavior on opacity {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: root.playing ? 220 : 170
                easing.type: root.playing ? Easing.OutBack : Easing.InBack
                easing.overshoot: 1.05
            }
        }

        Repeater {
            model: root.barCount

            Rectangle {
                required property int index

                width: root.barWidth
                height: Math.max(root.minimumBarHeight, root.maximumBarHeight * root.normalizedBarHeight(index))
                radius: root.radius
                color: root.color
                y: Math.round((root.height - height) / 2)
                opacity: root.playing ? 1 : 0.72

                Behavior on height {
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
