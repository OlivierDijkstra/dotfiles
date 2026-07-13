import QtQuick
import Quickshell
import Quickshell.Wayland
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

    readonly property int topMargin: 8

    Widgets.MediaState {
        id: mediaState
    }

    Widgets.VolumeState {
        id: volumeState
    }

    Widgets.AudioRouteState {
        id: audioRouteState
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
        Widgets.RecordingWidget {
            recordingState: recordingState
        },
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
    implicitHeight: topMargin + islandScaffold.implicitHeight

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
