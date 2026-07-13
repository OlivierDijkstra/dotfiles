import QtQuick
import ".." as Theme

Item {
    id: root

    readonly property string iconBasePath: "../../assets/icons/lucide"
    required property var volumeState
    property var audioRouteState: null
    property bool available: true
    property bool showMuteButton: true
    property bool showRouteButton: !!audioRouteState
    property int controlSize: 40
    // Keep the animated fill value separate from the bound volume so layout
    // resizes do not replay the bar from 0 when the media widget becomes visible.
    property real displayedVolumeVisual: volumeVisual
    property bool allowVolumeAnimation: false
    readonly property bool hasVolumeControl: !!volumeState && volumeState.hasVolumeControl
    readonly property real volumeVisual: volumeState ? volumeState.volumeVisual : 0
    readonly property string volumeIconName: volumeState && (volumeState.volumeMuted || volumeState.volumeLevel <= 0.001) ? "volume-x" : (volumeState && volumeState.volumeLevel < 0.5 ? "volume-1" : "volume-2")

    implicitWidth: volumeRail.implicitWidth
    implicitHeight: volumeRail.implicitHeight

    function setVolumeLevel(nextVolume) {
        if (!root.hasVolumeControl || !volumeState || !isFinite(nextVolume)) {
            return;
        }

        volumeState.setVolumeLevel(nextVolume);
    }

    function toggleMute() {
        if (!root.hasVolumeControl || !volumeState) {
            return;
        }

        volumeState.toggleMute();
    }

    function openAudioRoute() {
        if (!audioRouteState) {
            return;
        }

        audioRouteState.openPanel(audioRouteState.activePanel);
    }

    Component.onCompleted: {
        displayedVolumeVisual = volumeVisual;
        allowVolumeAnimation = true;
    }

    onVolumeVisualChanged: {
        displayedVolumeVisual = volumeVisual;
    }

    onVisibleChanged: {
        if (!visible) {
            // Snap back to the real value while hidden so the next reveal starts
            // from the current volume instead of animating through stale geometry.
            displayedVolumeVisual = volumeVisual;
        }
    }

    Behavior on displayedVolumeVisual {
        enabled: root.allowVolumeAnimation && root.visible && !volumeArea.pressed

        NumberAnimation {
            duration: 140
            easing.type: Easing.InOutQuad
        }
    }

    Item {
        id: volumeRail

        anchors.fill: parent
        opacity: root.hasVolumeControl ? 1 : 0.38
        implicitWidth: 168
                + (root.showMuteButton ? root.controlSize + 12 : 0)
                + (root.showRouteButton ? root.controlSize + 12 : 0)
        implicitHeight: root.controlSize

        Behavior on opacity {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        Item {
            id: volumeButton

            visible: root.showMuteButton
            width: visible ? root.controlSize : 0
            height: root.controlSize
            scale: volumeButtonArea.pressed ? 0.96 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: Math.round(root.controlSize * 0.35)
                color: volumeButtonArea.containsMouse ? Theme.Palette.hoverBackground : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 140
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Theme.ThemedIcon {
                anchors.centerIn: parent
                width: Math.round(root.controlSize * 0.45)
                height: width
                source: `${root.iconBasePath}/${root.volumeIconName}.svg`
                sourceSize.width: width
                sourceSize.height: height
            }

            MouseArea {
                id: volumeButtonArea

                anchors.fill: parent
                enabled: root.hasVolumeControl
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.toggleMute()
            }
        }

        Item {
            id: volumeSliderFrame

            anchors.left: parent.left
            anchors.leftMargin: root.showMuteButton ? (volumeButton.width + 12) : 0
            anchors.right: routeButton.visible ? routeButton.left : parent.right
            anchors.rightMargin: routeButton.visible ? 12 : 0
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height

            Rectangle {
                id: volumeTrack

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: volumeArea.pressed ? 7 : 6
                radius: height / 2
                color: Theme.Palette.trackBackground
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    id: volumeFill

                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * root.displayedVolumeVisual
                    radius: parent.radius
                    color: Theme.Palette.trackFill
                }
            }

            MouseArea {
                id: volumeArea

                anchors.fill: parent
                enabled: root.hasVolumeControl
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                function applyVolume(mouseX) {
                    root.setVolumeLevel(mouseX / width);
                }

                onPressed: mouse => applyVolume(mouse.x)
                onPositionChanged: mouse => {
                    if (pressed) {
                        applyVolume(mouse.x);
                    }
                }
                onWheel: wheel => {
                    wheel.accepted = true;
                    root.setVolumeLevel(root.volumeVisual + (wheel.angleDelta.y > 0 ? 0.05 : -0.05));
                }
            }
        }

        Item {
            id: routeButton

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showRouteButton
            width: visible ? root.controlSize : 0
            height: root.controlSize
            scale: routeButtonArea.pressed ? 0.96 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: Math.round(root.controlSize * 0.35)
                color: routeButtonArea.containsMouse ? Theme.Palette.hoverBackground : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 140
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Theme.ThemedIcon {
                anchors.centerIn: parent
                width: Math.round(root.controlSize * 0.45)
                height: width
                source: `${root.iconBasePath}/volume-2.svg`
                sourceSize.width: width
                sourceSize.height: height
                opacity: routeButtonArea.containsMouse ? 0.86 : 0.62
            }

            MouseArea {
                id: routeButtonArea

                anchors.fill: parent
                enabled: root.showRouteButton
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.openAudioRoute()
            }
        }
    }
}
