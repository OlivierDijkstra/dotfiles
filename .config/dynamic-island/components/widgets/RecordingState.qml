import QtQuick
import Quickshell.Io

Item {
    id: root

    visible: false

    readonly property string statusScript: "/home/oli/dotfiles/scripts/screenrecord-status"
    readonly property string toggleScript: "/home/oli/dotfiles/scripts/screenrecord"

    property bool recording: false
    property int elapsedSeconds: 0
    property string outputPath: ""
    readonly property string elapsedText: root.formatElapsed(elapsedSeconds)

    function formatElapsed(value) {
        const totalSeconds = Math.max(0, Math.floor(value));
        const hours = Math.floor(totalSeconds / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const seconds = totalSeconds % 60;
        const paddedMinutes = minutes < 10 && hours > 0 ? `0${minutes}` : `${minutes}`;
        const paddedSeconds = seconds < 10 ? `0${seconds}` : `${seconds}`;

        if (hours > 0) {
            return `${hours}:${paddedMinutes}:${paddedSeconds}`;
        }

        return `${minutes}:${paddedSeconds}`;
    }

    function applyStatus(rawStatus) {
        let nextStatus = {
            recording: false,
            elapsedSeconds: 0,
            outputPath: "",
        };

        try {
            const parsed = JSON.parse(rawStatus.trim());

            if (parsed && parsed.recording === true) {
                nextStatus = {
                    recording: true,
                    elapsedSeconds: Number(parsed.elapsedSeconds) || 0,
                    outputPath: parsed.outputPath || "",
                };
            }
        } catch (error) {
            console.warn(`failed to parse screen recording status: ${error}`);
        }

        root.recording = nextStatus.recording;
        root.elapsedSeconds = nextStatus.elapsedSeconds;
        root.outputPath = nextStatus.outputPath;
    }

    function refresh() {
        if (!statusProcess.running) {
            statusProcess.running = true;
        }
    }

    function stopRecording() {
        if (!root.recording || toggleProcess.running) {
            return;
        }

        toggleProcess.running = true;
        postToggleRefresh.restart();
    }

    Component.onCompleted: refresh()

    Process {
        id: statusProcess

        command: [root.statusScript]

        stdout: StdioCollector {
            onStreamFinished: root.applyStatus(this.text)
        }
    }

    Process {
        id: toggleProcess

        command: [root.toggleScript]
        onRunningChanged: {
            if (!running) {
                root.refresh();
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Timer {
        id: postToggleRefresh

        interval: 250
        onTriggered: root.refresh()
    }
}
