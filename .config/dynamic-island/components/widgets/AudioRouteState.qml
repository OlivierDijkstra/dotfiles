import QtQuick
import Quickshell.Io

Item {
    id: root

    visible: false
    width: 0
    height: 0

    property bool pickerOpen: false
    property string activePanel: "output"
    property var sinks: []
    property var sources: []
    readonly property var currentDevices: activePanel === "input" ? sources : sinks

    function normalizePanel(panel) {
        return panel === "input" ? "input" : "output";
    }

    function openPanel(panel) {
        const wasOpen = pickerOpen;

        activePanel = normalizePanel(panel);
        pickerOpen = true;

        if (wasOpen) {
            refreshDevices();
        }
    }

    function closePanel() {
        pickerOpen = false;
    }

    function parseDeviceLine(line) {
        const normalizedLine = line.replace(/^[\s│├└─]+/, "");
        const match = normalizedLine.match(/^(\*)?\s*(\d+)\.\s+(.+?)(?:\s+\[vol:[^\]]+\])?\s*$/);

        if (!match) {
            return null;
        }

        return {
            id: Number.parseInt(match[2], 10),
            name: match[3],
            isDefault: match[1] === "*",
        };
    }

    function applyStatus(output) {
        const nextSinks = [];
        const nextSources = [];
        const lines = output.split(/\r?\n/);
        let section = "";

        for (let index = 0; index < lines.length; index += 1) {
            const line = lines[index];

            if (line.indexOf("Sinks:") !== -1) {
                section = "output";
                continue;
            }

            if (line.indexOf("Sources:") !== -1) {
                section = "input";
                continue;
            }

            if (line.indexOf("Devices:") !== -1
                    || line.indexOf("Filters:") !== -1
                    || line.indexOf("Streams:") !== -1
                    || line.indexOf("Video") !== -1
                    || line.indexOf("Settings") !== -1) {
                section = "";
                continue;
            }

            if (!section) {
                continue;
            }

            const device = parseDeviceLine(line);

            if (!device) {
                continue;
            }

            if (section === "output") {
                nextSinks.push(device);
            } else {
                nextSources.push(device);
            }
        }

        sinks = nextSinks;
        sources = nextSources;

        if (activePanel === "output" && sinks.length === 0 && sources.length > 0) {
            activePanel = "input";
        } else if (activePanel === "input" && sources.length === 0 && sinks.length > 0) {
            activePanel = "output";
        }
    }

    function refreshDevices() {
        if (statusProcess.running) {
            return;
        }

        statusProcess.exec(["wpctl", "status"]);
    }

    function selectDevice(deviceId) {
        if (!deviceId) {
            return;
        }

        setDefaultProcess.exec(["wpctl", "set-default", `${deviceId}`]);
        refreshTimer.restart();
        closePanel();
    }

    onPickerOpenChanged: {
        if (pickerOpen) {
            refreshDevices();
        }
    }

    Timer {
        interval: 1500
        repeat: true
        running: root.pickerOpen
        onTriggered: root.refreshDevices()
    }

    Timer {
        id: refreshTimer

        interval: 180
        repeat: false
        onTriggered: root.refreshDevices()
    }

    Process {
        id: statusProcess

        stdout: StdioCollector {
            onStreamFinished: root.applyStatus(this.text)
        }
    }

    Process {
        id: setDefaultProcess
    }
}
