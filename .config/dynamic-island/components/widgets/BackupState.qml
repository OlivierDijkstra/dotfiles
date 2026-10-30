import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    visible: false
    width: 0
    height: 0

    // Written by /usr/local/sbin/oliarch-backup (see system/restic-oliarch).
    property string statusPath: "/var/lib/restic-oliarch/status.json"
    readonly property real staleAfterMs: 2 * 24 * 3600 * 1000
    // A run older than this was killed before it could record a result.
    readonly property real runningLimitMs: 12 * 3600 * 1000

    property var status: null
    property real now: Date.now()

    readonly property bool present: !!status
    readonly property real lastSuccess: present && status.last_success ? Date.parse(status.last_success) : 0
    readonly property real lastStart: present && status.last_start ? Date.parse(status.last_start) : 0
    readonly property bool checkFailed: present && status.last_check_result === "failed"
    readonly property bool running: present && status.state === "running" && now - lastStart < runningLimitMs
    readonly property string alertReason: {
        if (!present) {
            return "No backup status";
        }

        if (status.state === "failed") {
            return "Backup failed";
        }

        if (status.state === "running" && !running) {
            return "Backup interrupted";
        }

        if (checkFailed) {
            return "Repository check failed";
        }

        if (!running && now - lastSuccess > staleAfterMs) {
            return "Backup overdue";
        }

        return "";
    }
    readonly property bool alert: alertReason.length > 0
    readonly property string unitName: checkFailed && status.state !== "failed" ? "restic-oliarch-check" : "restic-oliarch-backup"
    readonly property string alertText: lastSuccess > 0 ? `${alertReason} · last success ${formatAgo(lastSuccess)}` : alertReason
    readonly property string summaryText: {
        if (running) {
            return `Backing up since ${formatAgo(lastStart).replace(" ago", "")}`;
        }

        if (lastSuccess <= 0) {
            return "No backup yet";
        }

        const added = present && status.data_added !== undefined ? ` · +${formatBytes(status.data_added)}` : "";
        return `Last backup ${formatAgo(lastSuccess)}${added}`;
    }
    readonly property string detailText: {
        if (!present) {
            return `${statusPath} not found`;
        }

        if (status.state === "failed" && status.error) {
            return status.error;
        }

        if (checkFailed && status.check_error) {
            return status.check_error;
        }

        return "";
    }
    readonly property string hintText: `journalctl -u ${unitName}`

    function formatAgo(time) {
        const minutes = Math.max(0, Math.floor((now - time) / 60000));

        if (minutes < 1) {
            return "just now";
        }

        if (minutes < 60) {
            return `${minutes}m ago`;
        }

        const hours = Math.floor(minutes / 60);
        return hours < 48 ? `${hours}h ago` : `${Math.floor(hours / 24)}d ago`;
    }

    function formatBytes(bytes) {
        const units = ["B", "KB", "MB", "GB", "TB"];
        let value = Math.max(0, Number(bytes) || 0);
        let unit = 0;

        while (value >= 1000 && unit < units.length - 1) {
            value /= 1000;
            unit += 1;
        }

        return unit === 0 ? `${value} B` : `${value.toFixed(1)} ${units[unit]}`;
    }

    function applyText(text) {
        try {
            root.status = JSON.parse(text);
        } catch (error) {
            console.warn(`failed to parse backup status: ${error}`);
            root.status = null;
        }
    }

    function openJournal() {
        Quickshell.execDetached(["ghostty", "-e", "journalctl", "--unit", `${unitName}.service`, "--pager-end"]);
    }

    // The backup script replaces the file atomically; FileView follows the rename.
    FileView {
        id: statusFile

        path: root.statusPath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.applyText(text())
        onLoadFailed: root.status = null
    }

    // Relative times and staleness only need minute resolution. Retry while the
    // file is missing, since its directory may not exist yet to be watched.
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            root.now = Date.now();

            if (!root.present) {
                statusFile.reload();
            }
        }
    }
}
