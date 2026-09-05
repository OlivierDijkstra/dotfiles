# Dynamic Island

A Quickshell panel for Arch Linux and Hyprland, anchored to the top of the screen.

## Structure

- `shell.qml`: transparent Wayland panel, shared state objects, and widget registry.
- `components/IslandStateController.qml`: selects a layout from availability, exclusive priority, and hover state.
- `components/IslandScaffold.qml`: coordinates content hiding, surface morphing, and content revealing.
- `components/IslandSurface.qml`: vector surface and animated geometry.
- `components/IslandWidgetHost.qml`: attaches widgets and handles temporary blur/fade transitions.
- `components/widgets/`: date/workspace, media, volume, recording, audio routing, network, and Bluetooth components.
- `components/Motion.js`: shared animation settings.
- `components/Palette.qml`: generated semantic colors; the island stays black in every desktop mode.

## Layouts and widgets

Widgets are declared in `shell.qml` and carry their own layout metadata:

- `layoutKey`
- `surfaceWidth`, `surfaceHeight`, and `surfaceRadius`
- `available`, and optionally `exclusive`

The controller gives the first available exclusive widget priority. Otherwise it selects the first available ordinary widget at rest, or the last on hover: the date/workspace pill and the expanded media controls respectively.

The host reparents widgets into a shared content item. Only the selected, available widget is visible. Hidden widgets retain their preferred dimensions, avoiding layout recalculation throughout unrelated surface animations.

Recording is a separate `RecordingBadge` beside the island, with a red indicator and elapsed time. Clicking it stops recording; hovering changes the indicator to a stop square. It stays visible alongside every layout, so recording does not prevent using or recording the island itself. A transparent input bridge keeps an expanded island open when moving into the badge. Entering the badge directly leaves a collapsed island in place.

## Audio and recording updates

`VolumeState` observes the default PipeWire sink, bound by `PwObjectTracker` in `shell.qml`. Volume and mute changes arrive as property updates, and slider/mute actions write directly to the audio node. External changes still show the volume OSD; initial synchronization, device switches, and local slider edits do not. Moving the slider also unmutes the sink.

`AudioRouteState` derives its device lists and default indicators from PipeWire's node model. Selecting a device sets PipeWire's preferred default source or sink. Audio controls no longer launch or poll `wpctl`. See [Quickshell's PipeWire types](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pipewire/Pipewire/).

`RecordingState` watches the recorder's PID and output-path files with `FileView`, querying status only at startup and on changes. While recording, `pidwait` watches process exit so a crash is detected even if the PID file remains. A local timer updates elapsed time once per second only while recording. This uses `pidwait` from `procps-ng`; no recurring recording-status subprocess runs while idle.

The badge invokes `screenrecord --stop`, which only stops an existing recording. The regular `screenrecord` command retains its start/stop toggle behavior.

## Rendering and transitions

The surface animates content width, height, and bottom radius with `220ms` `Easing.InOutCubic` Behaviors. Total width is derived from the animated content width and shoulders, so the content and surface stay aligned. Initial geometry is applied immediately, and later geometry changes can reverse from their current values without overshooting.

When the selected widget changes:

1. Fade and blur the outgoing content over `120ms`.
2. After hiding finishes, morph the surface to the latest requested layout.
3. Once all geometry animations stop, switch the widget and reveal it over `120ms`.

Animation completion drives these handoffs. Returning to the current widget while it is hiding cancels the exit. Requests during a morph retarget the geometry immediately. Equal-size layouts still hand off content even when no geometry animation starts.

Blur uses a single temporary item layer with `MultiEffect`, with a normalized blur amount of `0–1` and `blurMax = 16`. The layer is enabled only during visible transitions; settled and fully hidden content use no host blur layer. Fully hidden content is also marked invisible, and controls are disabled until the reveal completes. This follows [Qt's MultiEffect guidance](https://doc.qt.io/qt-6/qml-qtquick-effects-multieffect.html#performance).

The panel reserves enough backing-buffer height for its largest widget, while its input mask follows the visible island. Ordinary layout transitions therefore avoid resizing the Wayland buffer every frame. Widget size changes can still adjust the capacity; an in-flight surface is kept inside it.

## Styling

- Semantic colors are generated from `.config/theme/palette.json`.
- The date/time widget uses `Geist`, at `14px` and `Font.DemiBold`.

## Development

- `make run`: run the shell.
- `make lint`: lint all QML with the local Qt installation.
- `make test`: run audio-state, transition, rendered-pixel, and recorder lifecycle regression tests. Each QML suite gets its own offscreen OpenGL scene; the recorder test runs an isolated Quickshell instance with temporary status files and a harmless stand-in process.

Tests cover transition ordering and reversals, dynamic dimensions, blur-layer handoff, badge hover/stop behavior, volume/mute changes, audio-device hotplug, and recorder start/crash/restart events. They require Qt Quick Test, an OpenGL-capable Qt rendering backend, Quickshell, Python 3, and `procps-ng`. They do not change real audio settings or start a screen recording.
