import QtQuick
import Quickshell.Io

Item {
    id: root

    visible: false
    width: 0
    height: 0

    readonly property string themeScript: "/home/oli/dotfiles/scripts/theme-mode"

    property string mode: "dark"
    property string target: "dark"
    property string applied: "dark"
    property string source: ""
    property string statusError: ""
    property bool actionCommandActive: false

    readonly property bool busy: statusProcess.running || actionProcess.running

    function applyStatus(rawStatus) {
        let payload = null;

        try {
            payload = JSON.parse((rawStatus || "").trim() || "{}");
        } catch (error) {
            statusError = `Unable to parse theme status: ${error}`;
            return;
        }

        mode = payload.mode || "dark";
        target = payload.target || mode;
        applied = payload.applied || target;
        source = payload.source || "";
        statusError = "";
    }

    function refresh() {
        if (statusProcess.running) {
            return;
        }

        statusProcess.exec([themeScript, "status", "--json", "--sync-auto", "--quiet"]);
    }

    function runAction(commandName) {
        if (actionProcess.running) {
            return;
        }

        actionProcess.exec([themeScript, commandName, "--quiet"]);
    }

    function toggle() {
        runAction("toggle");
    }

    function setDark() {
        runAction("dark");
    }

    function setLight() {
        runAction("light");
    }

    function setAuto() {
        runAction("auto");
    }

    Component.onCompleted: refresh()

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: statusProcess

        stdout: StdioCollector {
            onStreamFinished: root.applyStatus(this.text)
        }
    }

    Process {
        id: actionProcess

        stderr: StdioCollector {
            id: actionError
        }

        onStarted: root.actionCommandActive = true

        onRunningChanged: {
            if (running || !root.actionCommandActive) {
                return;
            }

            root.actionCommandActive = false;
            root.statusError = (actionError.text || "").trim();
            root.refresh();
        }
    }
}
