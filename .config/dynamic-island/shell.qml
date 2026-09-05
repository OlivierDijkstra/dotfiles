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
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.anchors.top: true
    WlrLayershell.anchors.left: true
    WlrLayershell.anchors.right: true

    exclusionMode: ExclusionMode.Ignore
    focusable: false

    readonly property int topMargin: 0

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

    property list<Item> widgets: [
        Widgets.AudioRouteWidget {
            audioRouteState: audioRouteState
        },
        Widgets.NetworkWidget {
            networkState: networkState
        },
        Widgets.BluetoothWidget {
            bluetoothState: bluetoothState
        },
        Widgets.VolumeOsdWidget {
            volumeState: volumeState
            audioRouteState: audioRouteState
        },
        Widgets.DateTimeWidget {
            mediaState: mediaState
        },
        Widgets.MediaWidget {
            mediaState: mediaState
            volumeState: volumeState
            audioRouteState: audioRouteState
            networkState: networkState
            bluetoothState: bluetoothState
            themeModeState: themeModeState
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
        accessoryHovered: recordingBadge.hovered
    }

    Widgets.RecordingBadge {
        id: recordingBadge

        x: islandScaffold.x + islandScaffold.width
        y: root.topMargin
        recordingState: recordingState
    }

    mask: Region {
        item: islandScaffold.surfaceItem

        Region {
            item: recordingBadge.visible ? recordingBadge : null
        }
    }
}
