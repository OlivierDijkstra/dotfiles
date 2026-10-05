import QtQuick
import QtQuick.Effects
import ".." as Theme

Item {
    id: root
    property var recordingState: null

    property string layoutKey: "box"
    property int surfaceWidth: 384
    property int surfaceHeight: Math.max(190, Math.ceil(contentColumn.implicitHeight + (contentPadding * 2)))
    // Footer tiles use radius 14, so 14 + padding keeps the bottom corners concentric.
    property int surfaceRadius: 34
    property int contentPadding: 20
    required property var mediaState
    required property var volumeState
    property var audioRouteState: null
    property var networkState: null
    property var bluetoothState: null
    property var themeModeState: null
    property var keepAwakeState: null
    readonly property string iconBasePath: "../../assets/icons/lucide"

    readonly property bool available: true
    readonly property var player: mediaState ? mediaState.activePlayer : null
    readonly property bool hasPlayer: !!player
    readonly property bool isPlaying: hasPlayer && player.isPlaying
    readonly property bool hasArtwork: !!player && !!player.trackArtUrl
    readonly property real trackLength: player && player.length > 0 ? player.length : 0
    readonly property bool canSeek: hasPlayer && player.canSeek && player.positionSupported && trackLength > 0
    // While scrubbing, preview the target position without seeking until release.
    readonly property real shownPosition: scrubPosition >= 0 ? scrubPosition : displayPosition
    readonly property real progress: trackLength > 0 ? Math.max(0, Math.min(1, shownPosition / trackLength)) : 0
    readonly property string title: player && player.trackTitle ? player.trackTitle : (player && player.identity ? player.identity : "Media")
    readonly property string artist: player && player.trackArtist ? player.trackArtist : statusText
    readonly property string statusText: !hasPlayer ? "Nothing playing" : (isPlaying ? "Playing now" : "Paused")
    readonly property string elapsedTimeText: hasPlayer ? root.formatSeconds(root.shownPosition) : "0:00"
    readonly property string remainingTimeText: trackLength > 0 ? `-${root.formatSeconds(Math.max(0, root.trackLength - root.shownPosition))}` : "--:--"
    readonly property string networkIconName: !networkState ? "wifi-off" : (networkState.ethernetConnected ? "ethernet-port" : (networkState.wifiConnected ? (networkState.wifiSignal >= 67 ? "wifi" : (networkState.wifiSignal >= 34 ? "wifi-high" : "wifi-low")) : "wifi-off"))
    readonly property string bluetoothIconName: !bluetoothState || !bluetoothState.adapterAvailable || !bluetoothState.adapterEnabled ? "bluetooth-off" : (bluetoothState.connectedDeviceCount > 0 ? "bluetooth-connected" : "bluetooth")
    readonly property string themeModeIconName: !themeModeState ? "moon" : (themeModeState.mode === "auto" ? "sun-moon" : (themeModeState.target === "light" ? "sun" : "moon"))
    property real displayPosition: 0
    property real scrubPosition: -1

    visible: false

    function formatSeconds(value) {
        const totalSeconds = Math.max(0, Math.floor(value));
        const hours = Math.floor(totalSeconds / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const seconds = totalSeconds % 60;
        const paddedSeconds = seconds < 10 ? `0${seconds}` : `${seconds}`;

        if (hours > 0) {
            const paddedMinutes = minutes < 10 ? `0${minutes}` : `${minutes}`;
            return `${hours}:${paddedMinutes}:${paddedSeconds}`;
        }

        return `${minutes}:${paddedSeconds}`;
    }

    function syncDisplayPosition() {
        if (!player || player.position < 0) {
            displayPosition = 0;
            return;
        }

        displayPosition = trackLength > 0 ? Math.min(player.position, trackLength) : player.position;
    }

    onPlayerChanged: syncDisplayPosition()
    onTrackLengthChanged: syncDisplayPosition()

    Connections {
        target: root.player
        ignoreUnknownSignals: true

        function onPositionChanged() {
            root.syncDisplayPosition();
        }

        function onLengthChanged() {
            root.syncDisplayPosition();
        }

        function onPlaybackStateChanged() {
            if (!root.player || !root.player.isPlaying) {
                root.syncDisplayPosition();
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: !!root.player && root.player.isPlaying
        onTriggered: {
            const nextPosition = root.displayPosition + 1;
            root.displayPosition = root.trackLength > 0 ? Math.min(nextPosition, root.trackLength) : nextPosition;
        }
    }

    component IconButton: Item {
        id: button

        property url source
        property int iconSize: 18
        property real iconOffset: 0
        property bool filled: false
        property bool checked: false
        property string label: ""
        property color iconColor: checked ? Theme.Palette.accentForeground : Theme.Palette.foreground
        property alias acceptedButtons: buttonArea.acceptedButtons

        signal clicked(var mouse)
        signal wheelMoved(var wheel)

        width: 40
        height: 40
        opacity: enabled ? 1 : 0.38
        scale: buttonArea.pressed ? 0.96 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 14
            color: button.checked ? (buttonArea.containsMouse ? Theme.Palette.secondaryForeground : Theme.Palette.accent) : (buttonArea.containsMouse ? Theme.Palette.hoverBackground : (button.filled ? Theme.Palette.surface2 : "transparent"))

            Behavior on color {
                ColorAnimation {
                    duration: 140
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Row {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: button.iconOffset
            spacing: 6

            Theme.ThemedIcon {
                anchors.verticalCenter: parent.verticalCenter
                width: button.iconSize
                height: button.iconSize
                source: button.source
                sourceSize.width: width
                sourceSize.height: height
                color: button.iconColor
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: text.length > 0
                text: button.label
                color: button.iconColor
                font.family: "Geist Mono"
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }

        MouseArea {
            id: buttonArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => button.clicked(mouse)
            onWheel: wheel => button.wheelMoved(wheel)
        }
    }

    Column {
        id: contentColumn

        anchors.fill: parent
        anchors.margins: root.contentPadding
        spacing: 12

        Item {
            width: parent.width
            height: artworkFrame.height

            Rectangle {
                id: artworkFrame

                width: 56
                height: 56
                radius: 14
                color: Theme.Palette.surface2

                Image {
                    id: artwork

                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: root.hasArtwork ? root.player.trackArtUrl : ""
                    asynchronous: true
                    sourceSize.width: artworkFrame.width * 2
                    sourceSize.height: artworkFrame.height * 2
                    visible: false
                }

                Rectangle {
                    id: artworkMask

                    anchors.fill: parent
                    radius: artworkFrame.radius
                    visible: false
                    color: "#ffffff"
                    layer.enabled: true
                    antialiasing: true
                }

                MultiEffect {
                    anchors.fill: parent
                    visible: artwork.status === Image.Ready
                    source: artwork
                    maskEnabled: true
                    maskSource: artworkMask
                    autoPaddingEnabled: false
                }

                Rectangle {
                    anchors.fill: parent
                    visible: artwork.status !== Image.Ready
                    radius: artworkFrame.radius

                    gradient: Gradient {
                        GradientStop {
                            position: 0
                            color: Theme.Palette.surface4
                        }
                        GradientStop {
                            position: 1
                            color: Theme.Palette.surface6
                        }
                    }
                }

                Theme.ThemedIcon {
                    anchors.centerIn: parent
                    visible: artwork.status !== Image.Ready
                    width: 20
                    height: 20
                    source: `${root.iconBasePath}/audio-lines.svg`
                    opacity: root.hasPlayer ? 1 : 0.72
                    sourceSize.width: width
                    sourceSize.height: height
                }

                Rectangle {
                    anchors.fill: parent
                    radius: artworkFrame.radius
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)
                }
            }

            Column {
                anchors.left: artworkFrame.right
                anchors.leftMargin: 14
                anchors.right: playingIndicator.left
                anchors.rightMargin: playingIndicator.width > 0 ? 12 : 0
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3

                Text {
                    width: parent.width
                    color: Theme.Palette.foreground
                    text: root.title
                    elide: Text.ElideRight
                    font.family: "Geist"
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width
                    color: Theme.Palette.mutedForeground
                    text: root.artist
                    elide: Text.ElideRight
                    visible: text.length > 0
                    font.family: "Geist"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }

            Item {
                id: playingIndicator

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: root.isPlaying ? indicatorGlyph.implicitWidth : 0
                height: indicatorGlyph.implicitHeight
                clip: true

                MusicIndicator {
                    id: indicatorGlyph

                    anchors.centerIn: parent
                    playing: root.isPlaying
                    barWidth: 3
                    barSpacing: 2
                    minimumBarHeight: 5
                    maximumBarHeight: 16
                }
            }
        }

        Column {
            width: parent.width
            spacing: 6

            Item {
                width: parent.width
                height: 4

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: progressArea.containsMouse || progressArea.pressed ? 6 : 4
                    radius: height / 2
                    color: Theme.Palette.trackBackground

                    Behavior on height {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        width: parent.width * root.progress
                        height: parent.height
                        radius: parent.radius
                        color: Theme.Palette.trackFill
                    }
                }

                MouseArea {
                    id: progressArea

                    function positionAt(mouseX) {
                        return Math.max(0, Math.min(1, mouseX / width)) * root.trackLength;
                    }

                    // Extend the thin bar's hit area into the surrounding spacing.
                    anchors.fill: parent
                    anchors.topMargin: -8
                    anchors.bottomMargin: -6
                    enabled: root.canSeek
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onPressed: mouse => root.scrubPosition = positionAt(mouse.x)
                    onPositionChanged: mouse => {
                        if (pressed) {
                            root.scrubPosition = positionAt(mouse.x);
                        }
                    }
                    onReleased: {
                        root.player.position = root.scrubPosition;
                        root.displayPosition = root.scrubPosition;
                        root.scrubPosition = -1;
                    }
                    onCanceled: root.scrubPosition = -1
                }
            }

            Item {
                width: parent.width
                height: elapsedTimeLabel.implicitHeight

                Text {
                    id: elapsedTimeLabel

                    color: Theme.Palette.mutedForeground
                    text: root.elapsedTimeText
                    font.family: "Geist Mono"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }

                Text {
                    anchors.right: parent.right
                    color: Theme.Palette.mutedForeground
                    text: root.remainingTimeText
                    font.family: "Geist Mono"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }
            }
        }

        // Rows are sized to their glyphs rather than their hit areas, so the
        // visible gaps stay even; the larger buttons overflow into the spacing.
        Item {
            width: parent.width
            height: 32

            Row {
                anchors.centerIn: parent
                spacing: 16

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    height: 36
                    iconSize: 16
                    enabled: !!root.player && root.player.canGoPrevious
                    source: `${root.iconBasePath}/skip-back.svg`
                    onClicked: root.player.previous()
                }

                IconButton {
                    iconSize: 20
                    iconOffset: root.isPlaying ? 0 : 1
                    enabled: !!root.player && root.player.canTogglePlaying
                    source: root.isPlaying ? `${root.iconBasePath}/pause.svg` : `${root.iconBasePath}/play.svg`
                    onClicked: root.player.togglePlaying()
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    height: 36
                    iconSize: 16
                    enabled: !!root.player && root.player.canGoNext
                    source: `${root.iconBasePath}/skip-forward.svg`
                    onClicked: root.player.next()
                }
            }
        }

        Item {
            width: parent.width
            height: 28

            // Offset by the icon inset so the volume glyphs line up with the
            // artwork and text edges instead of their 40px hit areas.
            VolumeWidget {
                x: -11
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width + 22
                height: 40
                volumeState: root.volumeState
                audioRouteState: root.audioRouteState
            }
        }

        Row {
            id: footer

            readonly property int tileCount: (!!root.keepAwakeState) + (!!root.themeModeState) + (!!root.bluetoothState) + (!!root.networkState)
            readonly property real tileWidth: (width - (recordingIndicator.visible ? recordingIndicator.width + spacing : 0) - (spacing * (tileCount - 1))) / Math.max(1, tileCount)

            width: parent.width
            height: 40
            spacing: 8
            visible: recordingIndicator.recording || tileCount > 0

            RecordingIndicator {
                id: recordingIndicator

                anchors.verticalCenter: parent.verticalCenter
                recordingState: root.recordingState
            }

            // Click keeps the system awake until turned off; scroll sets a timer.
            IconButton {
                visible: !!root.keepAwakeState
                width: footer.tileWidth
                filled: true
                checked: !!root.keepAwakeState && root.keepAwakeState.active
                label: !!root.keepAwakeState && root.keepAwakeState.timed ? root.keepAwakeState.remainingText : ""
                source: `${root.iconBasePath}/coffee.svg`
                onClicked: root.keepAwakeState.toggle()
                onWheelMoved: wheel => {
                    if (wheel.angleDelta.y !== 0) {
                        root.keepAwakeState.adjust(wheel.angleDelta.y > 0 ? 1 : -1);
                    }
                }
            }

            IconButton {
                visible: !!root.themeModeState
                width: footer.tileWidth
                filled: true
                enabled: !!root.themeModeState && !root.themeModeState.busy
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                source: `${root.iconBasePath}/${root.themeModeIconName}.svg`

                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        root.themeModeState.setAuto();
                    } else {
                        root.themeModeState.toggle();
                    }
                }

                onWheelMoved: wheel => {
                    if (wheel.angleDelta.y > 0) {
                        root.themeModeState.setDark();
                    } else if (wheel.angleDelta.y < 0) {
                        root.themeModeState.setLight();
                    }
                }
            }

            IconButton {
                visible: !!root.bluetoothState
                width: footer.tileWidth
                filled: true
                source: `${root.iconBasePath}/${root.bluetoothIconName}.svg`
                onClicked: root.bluetoothState.openPanel()
            }

            IconButton {
                visible: !!root.networkState
                width: footer.tileWidth
                filled: true
                source: `${root.iconBasePath}/${root.networkIconName}.svg`
                iconColor: root.networkState && root.networkState.dnsFailing ? Theme.Palette.danger : Theme.Palette.foreground
                onClicked: root.networkState.openPanel()
            }
        }
    }
}

