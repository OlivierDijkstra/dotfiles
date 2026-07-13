import QtQuick
import QtQuick.Effects
import ".." as Theme

Item {
    id: root

    property string layoutKey: "box"
    property int surfaceWidth: 380
    property int surfaceHeight: Math.max(190, Math.ceil(contentColumn.implicitHeight + (contentPaddingVertical * 2)))
    property int surfaceRadius: 28
    property int contentPaddingHorizontal: 28
    property int contentPaddingVertical: 18
    required property var mediaState
    required property var volumeState
    property var audioRouteState: null
    property var networkState: null
    property var bluetoothState: null
    property var themeModeState: null
    readonly property string iconBasePath: "../../assets/icons/lucide"

    readonly property bool available: true
    readonly property var player: mediaState ? mediaState.activePlayer : null
    readonly property bool hasPlayer: !!player
    readonly property bool isPlaying: hasPlayer && player.isPlaying
    readonly property bool hasArtwork: !!player && !!player.trackArtUrl
    readonly property real trackLength: player && player.length > 0 ? player.length : 0
    readonly property real progress: trackLength > 0 ? Math.max(0, Math.min(1, displayPosition / trackLength)) : 0
    readonly property string title: player && player.trackTitle ? player.trackTitle : (player && player.identity ? player.identity : "Media")
    readonly property string artist: player && player.trackArtist ? player.trackArtist : statusText
    readonly property string statusText: !hasPlayer ? "Nothing playing" : (isPlaying ? "Playing now" : "Paused")
    readonly property string elapsedTimeText: hasPlayer ? root.formatSeconds(root.displayPosition) : "0:00"
    readonly property string remainingTimeText: trackLength > 0 ? `-${root.formatSeconds(Math.max(0, root.trackLength - root.displayPosition))}` : "--:--"
    readonly property string networkIconName: !networkState ? "wifi-off" : (networkState.ethernetConnected ? "ethernet-port" : (networkState.wifiConnected ? (networkState.wifiSignal >= 67 ? "wifi" : (networkState.wifiSignal >= 34 ? "wifi-high" : "wifi-low")) : "wifi-off"))
    readonly property string bluetoothIconName: !bluetoothState || !bluetoothState.adapterAvailable || !bluetoothState.adapterEnabled ? "bluetooth-off" : (bluetoothState.connectedDeviceCount > 0 ? "bluetooth-connected" : "bluetooth")
    readonly property string themeModeIconName: !themeModeState ? "moon" : (themeModeState.mode === "auto" ? "sun-moon" : (themeModeState.target === "light" ? "sun" : "moon"))
    property real displayPosition: 0

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

    Column {
        id: contentColumn

        anchors.fill: parent
        anchors.leftMargin: root.contentPaddingHorizontal
        anchors.rightMargin: root.contentPaddingHorizontal
        anchors.topMargin: root.contentPaddingVertical
        anchors.bottomMargin: root.contentPaddingVertical
        spacing: 10

        Row {
            width: parent.width
            spacing: 12

            Rectangle {
                id: artworkFrame

                width: 60
                height: 60
                radius: 16
                color: Theme.Palette.surface2
                border.width: 1
                border.color: Theme.Palette.outline
                clip: true

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
                    radius: 12
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
                    color: root.hasPlayer ? "transparent" : Theme.Palette.surface2

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
            }

            Column {
                width: parent.width - artworkFrame.width - parent.spacing
                spacing: 8

                Row {
                    width: parent.width
                    spacing: 8

                    Column {
                        width: parent.width - playingIndicator.width - parent.spacing
                        spacing: 2

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

                Row {
                    id: progressRow

                    width: parent.width
                    height: Math.max(elapsedTimeLabel.implicitHeight, remainingTimeLabel.implicitHeight, 12)
                    spacing: 10

                    Item {
                        id: elapsedTimeFrame

                        width: 40
                        height: progressRow.height

                        Text {
                            id: elapsedTimeLabel

                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            horizontalAlignment: Text.AlignLeft
                            color: Theme.Palette.mutedForeground
                            text: root.elapsedTimeText
                            font.family: "Geist Mono"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }
                    }

                    Item {
                        width: Math.max(0, progressRow.width - elapsedTimeFrame.width - remainingTimeFrame.width - (progressRow.spacing * 2))
                        height: progressRow.height

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 4
                            radius: 2
                            color: Theme.Palette.trackBackground
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width * root.progress
                            height: 4
                            radius: 2
                            color: Theme.Palette.trackFill
                        }
                    }

                    Item {
                        id: remainingTimeFrame

                        width: 64
                        height: progressRow.height

                        Text {
                            id: remainingTimeLabel

                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            horizontalAlignment: Text.AlignRight
                            color: Theme.Palette.mutedForeground
                            text: root.remainingTimeText
                            font.family: "Geist Mono"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }
                    }
                }

                Item {
                    width: Math.max(0, parent.width - 22)
                    height: 40

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8

                        Item {
                            width: 40
                            height: 40
                            opacity: !!root.player && root.player.canGoPrevious ? 1 : 0.38
                            scale: previousArea.pressed ? 0.96 : 1

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: previousArea.containsMouse ? Theme.Palette.hoverBackground : "transparent"
                            }

                            Theme.ThemedIcon {
                                anchors.centerIn: parent
                                width: 18
                                height: 18
                                source: `${root.iconBasePath}/skip-back.svg`
                                sourceSize.width: width
                                sourceSize.height: height
                            }

                            MouseArea {
                                id: previousArea

                                anchors.fill: parent
                                enabled: !!root.player && root.player.canGoPrevious
                                hoverEnabled: true
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: root.player.previous()
                            }
                        }

                        Item {
                            width: 40
                            height: 40
                            opacity: !!root.player && root.player.canTogglePlaying ? 1 : 0.38
                            scale: playPauseArea.pressed ? 0.96 : 1

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: playPauseArea.containsMouse ? Theme.Palette.hoverBackground : "transparent"
                            }

                            Theme.ThemedIcon {
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: root.isPlaying ? 0 : 1
                                width: root.isPlaying ? 17 : 18
                                height: root.isPlaying ? 17 : 18
                                source: root.isPlaying ? `${root.iconBasePath}/pause.svg` : `${root.iconBasePath}/play.svg`
                                sourceSize.width: width
                                sourceSize.height: height
                            }

                            MouseArea {
                                id: playPauseArea

                                anchors.fill: parent
                                enabled: !!root.player && root.player.canTogglePlaying
                                hoverEnabled: true
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: root.player.togglePlaying()
                            }
                        }

                        Item {
                            width: 40
                            height: 40
                            opacity: !!root.player && root.player.canGoNext ? 1 : 0.38
                            scale: nextArea.pressed ? 0.96 : 1

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: nextArea.containsMouse ? Theme.Palette.hoverBackground : "transparent"
                            }

                            Theme.ThemedIcon {
                                anchors.centerIn: parent
                                width: 18
                                height: 18
                                source: `${root.iconBasePath}/skip-forward.svg`
                                sourceSize.width: width
                                sourceSize.height: height
                            }

                            MouseArea {
                                id: nextArea

                                anchors.fill: parent
                                enabled: !!root.player && root.player.canGoNext
                                hoverEnabled: true
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: root.player.next()
                            }
                        }
                    }
                }
            }
        }

        VolumeWidget {
            width: parent.width
            height: 40
            volumeState: root.volumeState
            audioRouteState: root.audioRouteState
        }

        Item {
            width: parent.width
            height: 40
            visible: !!root.themeModeState || !!root.networkState || !!root.bluetoothState
            opacity: visible ? 1 : 0

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Item {
                    id: themeModeButton

                    visible: !!root.themeModeState
                    width: visible ? 40 : 0
                    height: 40
                    scale: themeModeButtonArea.pressed ? 0.96 : 1
                    opacity: root.themeModeState && root.themeModeState.busy ? 0.72 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: themeModeButtonArea.containsMouse ? Theme.Palette.hoverBackground : Theme.Palette.surface2

                        Behavior on color {
                            ColorAnimation {
                                duration: 140
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    Theme.ThemedIcon {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        source: `${root.iconBasePath}/${root.themeModeIconName}.svg`
                        sourceSize.width: width
                        sourceSize.height: height
                        opacity: themeModeButtonArea.containsMouse ? 1 : 0.9
                    }

                    MouseArea {
                        id: themeModeButtonArea

                        anchors.fill: parent
                        enabled: !!root.themeModeState && !root.themeModeState.busy
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onClicked: mouse => {
                            if (!root.themeModeState) {
                                return;
                            }

                            if (mouse.button === Qt.RightButton) {
                                root.themeModeState.setAuto();
                                return;
                            }

                            root.themeModeState.toggle();
                        }

                        onWheel: wheel => {
                            if (!root.themeModeState) {
                                return;
                            }

                            if (wheel.angleDelta.y > 0) {
                                root.themeModeState.setDark();
                            } else if (wheel.angleDelta.y < 0) {
                                root.themeModeState.setLight();
                            }

                            wheel.accepted = true;
                        }
                    }
                }

                Item {
                    id: bluetoothButton

                    visible: !!root.bluetoothState
                    width: visible ? 40 : 0
                    height: 40
                    scale: bluetoothButtonArea.pressed ? 0.96 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: bluetoothButtonArea.containsMouse ? Theme.Palette.hoverBackground : Theme.Palette.surface2

                        Behavior on color {
                            ColorAnimation {
                                duration: 140
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    Theme.ThemedIcon {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        source: `${root.iconBasePath}/${root.bluetoothIconName}.svg`
                        sourceSize.width: width
                        sourceSize.height: height
                        opacity: bluetoothButtonArea.containsMouse ? 1 : 0.9
                    }

                    MouseArea {
                        id: bluetoothButtonArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.bluetoothState) {
                                root.bluetoothState.openPanel();
                            }
                        }
                    }
                }

                Item {
                    id: networkButton

                    visible: !!root.networkState
                    width: visible ? 40 : 0
                    height: 40
                    scale: networkButtonArea.pressed ? 0.96 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: networkButtonArea.containsMouse ? Theme.Palette.hoverBackground : Theme.Palette.surface2

                        Behavior on color {
                            ColorAnimation {
                                duration: 140
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    Theme.ThemedIcon {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        source: `${root.iconBasePath}/${root.networkIconName}.svg`
                        sourceSize.width: width
                        sourceSize.height: height
                        opacity: networkButtonArea.containsMouse ? 1 : 0.9
                    }

                    MouseArea {
                        id: networkButtonArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.networkState) {
                                root.networkState.openPanel();
                            }
                        }
                    }
                }
            }
        }
    }
}
