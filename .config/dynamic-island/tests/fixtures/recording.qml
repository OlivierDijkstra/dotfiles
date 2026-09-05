import QtQuick
import Quickshell
import "../../components/widgets" as Widgets

ShellRoot {
    id: root

    function report() {
        console.log("ISLAND_TEST_STATUS " + JSON.stringify({
            recording: recording.recording,
            elapsed: recording.elapsedSeconds,
            path: recording.outputPath,
        }))
    }

    Widgets.RecordingState {
        id: recording
        pidFilePath: Quickshell.env("ISLAND_TEST_PIDFILE")
        pathFilePath: Quickshell.env("ISLAND_TEST_PATHFILE")
        onRecordingChanged: root.report()
        onElapsedSecondsChanged: root.report()
        onOutputPathChanged: root.report()
    }

    Component.onCompleted: report()
}
