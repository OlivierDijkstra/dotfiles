# Dynamic Island

Small Quickshell experiment for Arch Linux on Wayland.

The goal is to build a simple dynamic island style component that sits at the top of the screen and can expand for lightweight status or interaction UI.

Right now this repo contains a small layout system, a widget system, and the transition coordination between them.

## Current structure

- `shell.qml`: top-level `PanelWindow`, layout registry, widget registry, and debug toggle wiring.
- `components/IslandLayout.qml`: layout descriptor type.
- `components/IslandStateController.qml`: chooses the requested layout from hover state or debug selection.
- `components/IslandScaffold.qml`: transition coordinator between requested layout, displayed layout, and widget visibility.
- `components/IslandSurface.qml`: the black island surface that morphs between layout sizes.
- `components/IslandWidgetHost.qml`: renders widgets and handles widget blur/fade transitions.
- `components/widgets/`: concrete widget implementations.
- `components/Motion.js`: shared motion constants.
- `components/Palette.qml`: generated dark surface palette; the island stays pure black in every desktop mode.

## Layouts

Layouts are declared in `shell.qml` as `IslandLayout` objects. Each layout defines:

- `key`
- `label`
- `width`
- `height`
- optional `radius`
- optional `hint`

At the moment the debug menu exposes four layouts:

- `pill`: default resting state
- `box`: large expanded window
- `elongated-pill`: wide lightweight state
- `small-box`: compact stacked state

The state controller decides which layout is requested. In auto mode, hover moves from the collapsed layout to the hover layout. In debug mode, the selected layout overrides that behavior.

## Widgets

Widgets are declared separately from layouts through `IslandWidgetSpec` entries in `shell.qml`.

Each widget spec currently defines:

- `key`
- `component`
- `visibleLayouts`
- `preferredWidth`
- `preferredHeight`

`visibleLayouts` determines which layouts a widget is allowed to render in. Widgets can also expose runtime availability so layouts do not try to reveal content that is currently empty.

Current widgets:

- `DateTimeWidget`, visible in `pill`
- `MediaWidget`, visible in `box` while an MPRIS player is actively playing

`IslandWidgetHost` renders the active widgets through `Loader` instances, centered in the island. This is intentionally simple for now and is a base for future placement rules or slots once multiple widgets need to coexist.

## Animation flow

The island shape and the widget content are coordinated as separate steps.

### Layout morph

The island surface morph uses a shared `IslandMorphAnimation`:

- duration: `220ms`
- easing: `Easing.OutBack`
- overshoot: `1`

This same morph animation is applied to `width`, `height`, and `radius`, so the geometry starts and finishes together.

### Widget transition sequence

When a new layout is requested, the transition order is:

1. Fade and blur out the currently visible widget.
2. After the widget hide transition completes, start the island layout morph.
3. Wait for the morph to finish.
4. Switch the widget layout key to the new layout.
5. Blur and fade the new widget back in.

This sequencing is owned by `IslandScaffold.qml`, while `IslandWidgetHost.qml` only performs the actual hide/reveal effect.

### Widget blur/fade

Widget transitions currently use values from `components/Motion.js`:

- `widgetTransitionDuration = 120`
- `widgetBlur = 1.6`
- `widgetBlurMax = 32`

The host renders widget content into a `ShaderEffectSource` and applies `MultiEffect` on top of it, so the blur is visible during hide and reveal instead of the widget simply disappearing.

## Styling

- Surface and semantic colors are generated from `.config/theme/palette.json`.
- The current date/time widget uses `Geist` explicitly.
- The date/time text is currently `14px` and `Font.DemiBold`.

## Development

- Run normally with `make run`
- Run with debug layout picker using `make run-debug`
- Lint all QML files with `make lint`
