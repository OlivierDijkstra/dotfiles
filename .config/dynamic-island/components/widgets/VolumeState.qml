import QtQuick
import Quickshell.Io

Item {
    id: root

    visible: false
    width: 0
    height: 0

    property bool hasVolumeControl: true
    property real volumeLevel: 0
    property bool volumeMuted: false
    readonly property real volumeVisual: volumeMuted ? 0 : volumeLevel
    property bool osdActive: false
    property bool osdHovered: false
    readonly property bool osdVisible: osdActive || osdHovered
    property bool initialized: false
    property real lastObservedVolumeLevel: 0
    property bool lastObservedMuted: false
    property real suppressOsdUntil: 0

    function clampUnitValue(value) {
        if (!isFinite(value)) {
            return 0;
        }

        return Math.max(0, Math.min(1, value));
    }

    function rememberObservedState(level, muted) {
        lastObservedVolumeLevel = level;
        lastObservedMuted = muted;
        initialized = true;
    }

    function nowMs() {
        return Date.now();
    }

    function maybeShowOsd(level, muted) {
        if (!initialized) {
            rememberObservedState(level, muted);
            return;
        }

        const levelChanged = Math.abs(level - lastObservedVolumeLevel) > 0.009;
        const mutedChanged = muted !== lastObservedMuted;

        if (nowMs() < suppressOsdUntil) {
            rememberObservedState(level, muted);
            return;
        }

        if (levelChanged || mutedChanged) {
            osdActive = true;
            osdTimer.restart();
        }

        rememberObservedState(level, muted);
    }

    function parseVolumeOutput(output) {
        const match = output.match(/Volume:\s+([0-9.]+)/);

        if (!match) {
            hasVolumeControl = false;
            return;
        }

        const parsedVolume = Number.parseFloat(match[1]);

        if (!isFinite(parsedVolume)) {
            hasVolumeControl = false;
            return;
        }

        const nextLevel = clampUnitValue(parsedVolume);
        const nextMuted = /\[MUTED\]/i.test(output);

        hasVolumeControl = true;
        volumeLevel = nextLevel;
        volumeMuted = nextMuted;
        maybeShowOsd(nextLevel, nextMuted);
    }

    function refreshVolume() {
        volumeQueryProcess.exec(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]);
    }

    function setVolumeLevel(nextVolume) {
        if (!hasVolumeControl || !isFinite(nextVolume)) {
            return;
        }

        const clampedVolume = clampUnitValue(nextVolume);
        const roundedVolume = Number(clampedVolume.toFixed(2));
        volumeLevel = roundedVolume;
        volumeMuted = false;
        suppressOsdUntil = nowMs() + 1200;
        rememberObservedState(roundedVolume, false);
        volumeSetProcess.exec(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", roundedVolume.toFixed(2)]);
        volumeRefreshTimer.restart();
    }

    function toggleMute() {
        if (!hasVolumeControl) {
            return;
        }

        const nextMuted = !volumeMuted;
        volumeMuted = nextMuted;
        suppressOsdUntil = nowMs() + 1200;
        rememberObservedState(volumeLevel, nextMuted);
        volumeMuteProcess.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
        volumeRefreshTimer.restart();
    }

    Component.onCompleted: refreshVolume()

    Timer {
        id: volumePollTimer

        interval: 250
        repeat: true
        running: true
        onTriggered: root.refreshVolume()
    }

    Timer {
        id: volumeRefreshTimer

        interval: 120
        repeat: false
        onTriggered: root.refreshVolume()
    }

    Timer {
        id: osdTimer

        interval: 1600
        repeat: false
        onTriggered: root.osdActive = false
    }

    Process {
        id: volumeQueryProcess

        stdout: StdioCollector {
            onStreamFinished: root.parseVolumeOutput(this.text)
        }
    }

    Process {
        id: volumeSetProcess
    }

    Process {
        id: volumeMuteProcess
    }
}
