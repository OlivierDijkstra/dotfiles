---
name: quickshell-motion-principles
description: >
  Motion principles for Quickshell/QML interfaces on Wayland. Use when building or reviewing shell UI animation such as island expansion, hover states, panel reveals, status transitions, easing, timing, responsiveness, performance, and reduced-motion behavior. Merges the useful parts of the existing web-focused motion skills into a desktop UI workflow.
---

# Quickshell Motion Principles

Use this skill for motion decisions in this repo. It is tuned for a desktop shell component, not a marketing site.

## Core Stance

- Motion must clarify state, hierarchy, or interaction. If it is only decorative, cut it.
- Frequent actions should feel immediate. If users will trigger something constantly, reduce or remove animation.
- Keyboard-driven or rapid-repeat interactions should not feel delayed by motion.
- The island should feel precise and calm, with selective moments of delight rather than constant flourish.

## Default Decision Rules

Ask these questions first:

1. Is something entering or exiting attention? Use `ease-out`.
2. Is something already visible and changing size, position, or shape? Use `ease-in-out`.
3. Is this only a hover, tint, or subtle feedback transition? Use `ease`.
4. Will this happen dozens or hundreds of times per session? Prefer no animation or the shortest useful version.

Avoid `ease-in` for normal UI feedback. It delays the visible response and makes the shell feel sluggish.

## Timing

- Micro feedback: `100-140ms`
- Hover and small state changes: `120-180ms`
- Standard reveals and collapses: `160-240ms`
- Large panel or island expansion: `180-260ms`

Stay under `300ms` for normal shell UI. If an effect needs to be slower to read correctly, justify it.

## Quickshell / QML Implementation Rules

- Prefer `Behavior` with `NumberAnimation` or `PropertyAnimation` for state-driven transitions.
- Keep related parts synchronized. If the island body, mask, and inner content move together, they should share timing and easing.
- Prefer animating `opacity`, `scale`, `x`, `y`, or other visually cheap properties.
- Animate `width`, `height`, or `radius` only when the geometry change is the actual interaction and the component tree is small enough to keep smooth.
- Do not animate from `scale: 0`. Start near the resting shape, such as `0.96`, and combine with opacity if needed.
- Keep hover hit areas stable. If movement would cause flicker, animate a child item instead of the hovered container.
- Match the visual origin of motion to the interaction source. A top bar reveal should feel anchored to the top edge, not float from nowhere.
- Prefer interruptible transitions over one-shot flourishes. Rapid hover enter/leave or repeated toggles should reverse cleanly instead of snapping.

## Performance

- Keep the animated subtree small.
- Avoid stacking multiple expensive effects at once.
- Use blur, shadow, and masking deliberately. They are useful, but shell UI should not depend on heavy continuous effects.
- If an animation feels shaky, check for pixel snapping, conflicting bindings, or too many properties changing at once before increasing duration.

## Accessibility

- Support reduced motion by shortening or removing non-essential transitions.
- Avoid large zooms, aggressive bounce, or ornamental looping motion in the main shell surface.
- Functional state changes must remain understandable even when motion is reduced.

## Review Checklist

Before shipping a motion change, check:

- Is the animation helping orientation, feedback, or continuity?
- Is the chosen easing correct for enter/exit versus on-screen movement?
- Is the duration fast enough for a shell interaction?
- Do paired elements move like one system?
- Does repeated use still feel good after the tenth interaction?
- Does the interaction stay responsive when interrupted halfway through?
- Is reduced motion respected?
- Are we using restraint, polish, and delight in the right balance for a desktop utility?

## Design Lens

This skill combines three perspectives:

- Restraint and speed for high-frequency utility UI.
- Production polish for transitions, layering, and refinement.
- Selective delight where the island benefits from feeling alive.

When these principles conflict, prioritize responsiveness and clarity over spectacle.
