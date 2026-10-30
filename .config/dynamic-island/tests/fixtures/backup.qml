import QtQuick
import Quickshell
import "../../components/widgets" as Widgets

ShellRoot {
    id: root

    function report() {
        console.log("ISLAND_TEST_STATUS " + JSON.stringify({
            present: backup.present,
            alert: backup.alert,
            reason: backup.alertReason,
            title: backup.alertText,
            running: backup.running,
            summary: backup.summaryText,
            detail: backup.detailText,
            hint: backup.hintText,
            indicator: indicator.visible,
        }))
    }

    Widgets.BackupState {
        id: backup
        statusPath: Quickshell.env("ISLAND_TEST_BACKUP_STATUS")
        onStatusChanged: Qt.callLater(root.report)
    }

    // Items only report effective visibility inside a window.
    FloatingWindow {
        Widgets.BackupIndicator {
            id: indicator
            backupState: backup
        }
    }

    Component.onCompleted: report()
}
