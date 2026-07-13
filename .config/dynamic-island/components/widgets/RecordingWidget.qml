import QtQuick
import ".." as Theme

Item {
    id: root

    property string layoutKey: "recording-pill"
    property bool exclusive: true
    property int surfaceWidth: 356
    property int surfaceHeight: 92
    property int surfaceRadius: 30
    property int horizontalPadding: 20
    property int verticalPadding: 16
    required property var recordingState

    readonly property bool available: !!recordingState && recordingState.recording

    visible: false

    Row {
        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        anchors.topMargin: root.verticalPadding
        anchors.bottomMargin: root.verticalPadding
        spacing: 18

        Column {
            width: parent.width - stopButtonFrame.width - parent.spacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Row {
                height: Math.max(timerLabel.implicitHeight, 14)
                spacing: 8

                Item {
                    width: 14
                    height: 14
                    y: Math.round((parent.height - height) / 2)

                    Rectangle {
                        anchors.centerIn: parent
                        width: 14
                        height: 14
                        radius: 7
                        color: Theme.Palette.danger
                        opacity: 0.22
                        scale: 1

                        SequentialAnimation on scale {
                            running: root.available
                            loops: Animation.Infinite

                            NumberAnimation {
                                from: 1
                                to: 1.85
                                duration: 1400
                                easing.type: Easing.OutCubic
                            }
                        }

                        SequentialAnimation on opacity {
                            running: root.available
                            loops: Animation.Infinite

                            NumberAnimation {
                                from: 0.22
                                to: 0
                                duration: 1400
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 10
                        height: 10
                        radius: 5
                        color: Theme.Palette.danger
                    }
                }

                Text {
                    id: timerLabel

                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.Palette.danger
                    text: root.recordingState ? root.recordingState.elapsedText : "0:00"
                    font.family: "Geist Mono"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.3
                }
            }

            Text {
                width: parent.width
                color: Theme.Palette.foreground
                text: "Screen Recording"
                elide: Text.ElideRight
                font.family: "Geist"
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }
        }

        Item {
            id: stopButtonFrame

            width: 52
            height: 52
            anchors.verticalCenter: parent.verticalCenter
            scale: stopArea.pressed ? 0.96 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: 52
                height: 52
                radius: 26
                color: Theme.Palette.surface3
                opacity: stopArea.containsMouse ? 0.94 : 0.82
            }

            Rectangle {
                anchors.centerIn: parent
                width: 44
                height: 44
                radius: 22
                color: Theme.Palette.surface1
                border.width: 1
                border.color: stopArea.containsMouse ? Theme.Palette.foreground : Theme.Palette.borderStrong
            }

            Rectangle {
                anchors.centerIn: parent
                width: 18
                height: 18
                radius: 6
                color: Theme.Palette.danger
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
}
