# DolphiniOS Design Tokens — canonical spec

This is the canonical source of truth for the three-tier UI modernization
(`dolphin-ios-ui` = Tier 1 "classic", `dolphin-ios-ui-modern` = Tier 2,
`dolphin-ios-ui-glass` = Tier 3). Each tier hand-translates these values into
its own idiom — see `DesignTokens.json` for the machine-readable twin used
when porting to Tier 2/Swift-`enum` and Tier 3/`.glassEffect()` parameters.

**Do not share this file via submodule/symlink across the three repos.**
Copy it to the same relative path (`Source/iOS/App/DolphiniOS/DesignSystem/`)
when a tier's screen work starts, and note at the top of the copy which repo
is canonical (this one, Tier 1).

## Brand anchor

The existing Liquid-Glass app icon work (`DolphiniOS/AppIcon_Glass.icon/Assets/Dolphin_Emulator_Logo_Refresh-3.svg`)
already defines a signature gradient: `#3217ff → #2b38ff → #2455ff → #1d74ff → #1792ff`
("Dolphin Blue"). All three tiers should anchor their accent color on this
gradient rather than inventing a new brand color, for visual continuity with
work already shipped.

## Color roles (semantic, not literal hex — each tier resolves per light/dark)

| Token | Light | Dark | Notes |
|---|---|---|---|
| `color.background.primary` | `#F5F6F8` | `#0B0C10` | Screen background |
| `color.background.secondary` | `#FFFFFF` | `#16171C` | Card/cell background before glass overlay |
| `color.surface.glass` | white @ 62% over blur | white @ 8% over blur | The "glass" material tint — see Glass simulation note below |
| `color.accent.start` | `#3217FF` | `#3217FF` | Gradient start (Dolphin Blue) |
| `color.accent.end` | `#1792FF` | `#1792FF` | Gradient end |
| `color.accent.solid` | `#2455FF` | `#4B7CFF` | Single-value fallback (e.g. tab bar selected icon tint) — dark variant lightened for contrast |
| `color.text.primary` | `#101114` | `#F2F3F5` | |
| `color.text.secondary` | `#5B5F6B` | `#9BA0AC` | |
| `color.border.hairline` | black @ 8% | white @ 10% | |
| `color.destructive` | `#E5484D` | `#F2555A` | Standard system-red-adjacent, not brand-specific |
| `color.success` | `#2FB673` | `#3ECB86` | |

## Spacing scale

| Token | Value |
|---|---|
| `spacing.xs` | 4pt |
| `spacing.sm` | 8pt |
| `spacing.md` | 16pt |
| `spacing.lg` | 24pt |
| `spacing.xl` | 40pt |

## Corner radii

| Token | Value |
|---|---|
| `radius.sm` | 8pt |
| `radius.md` | 14pt |
| `radius.lg` | 22pt |
| `radius.pill` | 999pt (fully rounded) |

## Type scale

Built on Dynamic Type text styles so every tier gets accessibility scaling for
free — do not hardcode point sizes in screen code, always go through these
tokens.

| Token | Base UIFont.TextStyle | Weight | Notes |
|---|---|---|---|
| `type.display` | `.largeTitle` | `.bold` | Onboarding hero, empty states |
| `type.title` | `.title2` | `.semibold` | Screen/section titles |
| `type.headline` | `.headline` | `.semibold` | Cell titles, settings row labels |
| `type.body` | `.body` | `.regular` | Default body text |
| `type.caption` | `.footnote` | `.regular` | Secondary/metadata text |

## Motion

| Token | Value | Notes |
|---|---|---|
| `motion.duration.fast` | 0.18s | Micro-interactions (tab select, button press) |
| `motion.duration.standard` | 0.32s | Screen-level transitions, sheet presentation |
| `motion.duration.slow` | 0.5s | Onboarding page transitions |
| `motion.spring.standard` | damping 0.86, response 0.4 | `UISpringTimingParameters`-equivalent for `UIViewPropertyAnimator` |

## Haptics

| Token | UIFeedbackGenerator | Trigger examples |
|---|---|---|
| `haptics.selection` | `UISelectionFeedbackGenerator` | Tab switch, segmented control, list row tap |
| `haptics.success` | `UINotificationFeedbackGenerator(.success)` | NetPlay connect, save confirmation |
| `haptics.warning` | `UINotificationFeedbackGenerator(.warning)` | Destructive confirmation, connection lost |

## Glass simulation note (Tier 1 only)

Tier 1 has no native Liquid Glass API (needs iOS 26). Simulate it with
`UIVisualEffectView` (`.systemUltraThinMaterial` family) + a 1pt hairline
border (`color.border.hairline`) + a soft shadow (12pt blur, 6% opacity,
4pt y-offset). Tier 1's `color.surface.glass` opacity values above are
intentionally more conservative (more opaque) than what Tier 3 will use with
true `.glassEffect()`, because simulated blur reads as murky/low-contrast at
the same opacity a native compositor-level glass effect uses. **Do not flag
Tier 1 as "wrong" for not matching Tier 3 pixel-for-pixel** — this is a
deliberate per-tier adjustment documented here, not a mistake.

## Iconography

SF Symbols only, no custom icon font. Default weight matches
`type.headline`'s weight (`.semibold`) for visual consistency with text.
