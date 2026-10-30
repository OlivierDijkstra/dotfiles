import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import "components" as UI
import "components/widgets" as Widgets

PanelWindow {
    id: root

    color: "transparent"

    WlrLayershell.namespace: "dynamic-island"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: root.topMargin + dateTimeWidget.surfaceHeight + root.windowGap
    WlrLayershell.anchors.top: true
    WlrLayershell.anchors.left: true
    WlrLayershell.anchors.right: true

    exclusionMode: ExclusionMode.Normal
    focusable: false

    readonly property int topMargin: 0
    readonly property int windowGap: 0

    Widgets.MediaState {
        id: mediaState
    }

    Widgets.VolumeState {
        id: volumeState
        sink: Pipewire.defaultAudioSink
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Widgets.AudioRouteState {
        id: audioRouteState
        pipewire: Pipewire
    }

    Widgets.NetworkState {
        id: networkState
    }

    Widgets.BluetoothState {
        id: bluetoothState
    }

    Widgets.ThemeModeState {
        id: themeModeState
    }

    Widgets.RecordingState {
        id: recordingState
    }

    Widgets.KeepAwakeState {
        id: keepAwakeState
        window: root
    }

    Widgets.BackupState {
        id: backupState
    }

    property list<Item> widgets: [
        Widgets.AudioRouteWidget {
            recordingState: recordingState
            audioRouteState: audioRouteState
        },
        Widgets.NetworkWidget {
            recordingState: recordingState
            networkState: networkState
        },
        Widgets.BluetoothWidget {
            recordingState: recordingState
            bluetoothState: bluetoothState
        },
        Widgets.VolumeOsdWidget {
            recordingState: recordingState
            volumeState: volumeState
            audioRouteState: audioRouteState
        },
        Widgets.DateTimeWidget {
            id: dateTimeWidget
            recordingState: recordingState
            mediaState: mediaState
            keepAwakeState: keepAwakeState
            backupState: backupState
        },
        Widgets.MediaWidget {
            recordingState: recordingState
            mediaState: mediaState
            volumeState: volumeState
            audioRouteState: audioRouteState
            networkState: networkState
            bluetoothState: bluetoothState
            themeModeState: themeModeState
            keepAwakeState: keepAwakeState
            backupState: backupState
        }
    ]

    UI.IslandStateController {
        id: stateController

        layouts: root.widgets
    }

    implicitWidth: Screen.width
    readonly property int maximumWidgetHeight: Math.ceil(widgets.reduce((height, widget) => Math.max(height, widget.surfaceHeight), 0))

    // Keep the Wayland buffer steady during morphs; the input mask below still
    // follows the visible surface. Resize only when widget requirements change.
    implicitHeight: Math.ceil(Math.max(islandScaffold.implicitHeight, topMargin + maximumWidgetHeight))

    UI.IslandScaffold {
        id: islandScaffold

        x: Math.round((parent.width - width) / 2)
        y: 0

        controller: stateController
        widgets: root.widgets
        topMargin: root.topMargin
    }

    mask: Region {
        item: islandScaffold.surfaceItem
    }
}
