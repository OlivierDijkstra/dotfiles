import QtQuick
import Quickshell.Io

Item {
    id: root

    visible: false

    readonly property string statusScript: "/home/oli/dotfiles/scripts/screenrecord-status"
    readonly property string toggleScript: "/home/oli/dotfiles/scripts/screenrecord"
    property string pidFilePath: "/tmp/screenrecord.pid"
    property string pathFilePath: "/tmp/screenrecord.path"

    property bool recording: false
    property int elapsedSeconds: 0
    property real startedAt: 0
    property string outputPath: ""
    property bool refreshPending: false
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
            pid: 0,
        };

        try {
            const parsed = JSON.parse(rawStatus.trim());

            if (parsed && parsed.recording === true) {
                nextStatus = {
                    recording: true,
                    elapsedSeconds: Number(parsed.elapsedSeconds) || 0,
                    outputPath: parsed.outputPath || "",
                    pid: Number(parsed.pid) || 0,
                };
            }
        } catch (error) {
            console.warn(`failed to parse screen recording status: ${error}`);
        }

        root.recording = nextStatus.recording;
        root.elapsedSeconds = nextStatus.elapsedSeconds;
        root.outputPath = nextStatus.outputPath;
        root.startedAt = Date.now() - nextStatus.elapsedSeconds * 1000;

        if (nextStatus.recording && nextStatus.pid > 0 && !exitWatcher.running) {
            exitWatcher.exec(["pidwait", "-p", `${nextStatus.pid}`]);
        }
    }

    function refresh() {
        if (!statusProcess.running) {
            refreshPending = false;
            statusProcess.running = true;
        } else {
            refreshPending = true;
        }
    }

    function stopRecording() {
        if (!root.recording || toggleProcess.running) {
            return;
        }

        toggleProcess.running = true;
    }

    Component.onCompleted: refresh()

    Process {
        id: statusProcess

        command: [root.statusScript, root.pidFilePath, root.pathFilePath]
        onRunningChanged: {
            if (!running && root.refreshPending) {
                Qt.callLater(root.refresh);
            }
        }

        stdout: StdioCollector {
            onStreamFinished: root.applyStatus(this.text)
        }
    }

    Process {
        id: toggleProcess

        command: [root.toggleScript, "--stop"]
        onRunningChanged: {
            if (!running) {
                Qt.callLater(root.refresh);
            }
        }
    }

    // FileView watches creation, replacement, and removal as well as writes.
    FileView {
        path: root.pidFilePath
        watchChanges: true
        printErrors: false
        onFileChanged: Qt.callLater(root.refresh)
    }

    FileView {
        path: root.pathFilePath
        watchChanges: true
        printErrors: false
        onFileChanged: Qt.callLater(root.refresh)
    }

    // pidwait sleeps on the kernel's process-exit event, catching crashes even
    // when the recorder leaves a stale PID file. It only runs while recording.
    Process {
        id: exitWatcher
        onRunningChanged: {
            if (!running) {
                Qt.callLater(root.refresh);
            }
        }
    }

    Timer {
        interval: 1000
        running: root.recording
        repeat: true
        onTriggered: root.elapsedSeconds = Math.max(0, Math.floor((Date.now() - root.startedAt) / 1000))
    }
}
