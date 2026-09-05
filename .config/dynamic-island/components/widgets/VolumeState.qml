import QtQuick

Item {
    id: root

    required property var sink
    readonly property var audio: sink && sink.ready ? sink.audio : null
    readonly property bool hasVolumeControl: !!audio
    readonly property real volumeLevel: audio ? clampUnitValue(audio.volume) : 0
    readonly property bool volumeMuted: audio ? audio.muted : false
    readonly property real volumeVisual: volumeMuted ? 0 : volumeLevel
    property bool osdActive: false
    property bool osdHovered: false
    readonly property bool osdVisible: osdActive || osdHovered
    property bool initialized: false
    property real lastObservedVolumeLevel: 0
    property bool lastObservedMuted: false
    property real suppressOsdUntil: 0

    visible: false

    function clampUnitValue(value) {
        return isFinite(value) ? Math.max(0, Math.min(1, value)) : 0;
    }

    function rememberObservedState() {
        lastObservedVolumeLevel = volumeLevel;
        lastObservedMuted = volumeMuted;
        initialized = true;
    }

    function observeVolume() {
        if (!hasVolumeControl) {
            initialized = false;
            osdActive = false;
            osdHovered = false;
            osdTimer.stop();
            return;
        }

        const changed = Math.abs(volumeLevel - lastObservedVolumeLevel) > 0.009
            || volumeMuted !== lastObservedMuted;

        if (initialized && changed && Date.now() >= suppressOsdUntil) {
            osdActive = true;
            osdTimer.restart();
        }

        rememberObservedState();
    }

    function setVolumeLevel(nextVolume) {
        if (!hasVolumeControl || !isFinite(nextVolume)) {
            return;
        }

        suppressOsdUntil = Date.now() + 1200;
        audio.volume = Math.round(clampUnitValue(nextVolume) * 100) / 100;
        audio.muted = false;
    }

    function toggleMute() {
        if (hasVolumeControl) {
            suppressOsdUntil = Date.now() + 1200;
            audio.muted = !audio.muted;
        }
    }

    // Coalesce channel/mute updates and wait for a newly bound sink to be ready.
    // Initial sync and device switches should never produce a volume popup.
    onSinkChanged: {
        initialized = false;
        suppressOsdUntil = 0;
        osdActive = false;
        osdHovered = false;
        osdTimer.stop();
        Qt.callLater(observeVolume);
    }
    onAudioChanged: {
        initialized = false;
        Qt.callLater(observeVolume);
    }
    onVolumeLevelChanged: Qt.callLater(observeVolume)
    onVolumeMutedChanged: Qt.callLater(observeVolume)
    Component.onCompleted: Qt.callLater(observeVolume)

    Timer {
        id: osdTimer

        interval: 1600
        onTriggered: root.osdActive = false
    }
}
