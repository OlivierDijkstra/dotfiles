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
- `make test`: run transition and rendered-pixel regression tests in an offscreen OpenGL scene, without starting shell services.

Tests cover transition ordering, rapid requests, reversal during each phase, equal-size layouts, dynamic dimensions, hidden-panel sizing, and blur-layer handoff. They require Qt Quick Test and an OpenGL-capable Qt rendering backend.
