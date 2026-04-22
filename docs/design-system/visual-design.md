# Soliplex Visual Design System

Version 1.0 --- 2026-04-22

---

## Section 0 --- How to use this document

This document is the canonical reference for the Soliplex design system.
It describes every primitive, every theming surface, every component
contract, and every accessibility floor that governs the visual layer of
the Soliplex frontend. When this document and the code disagree, file a
bug --- one of them is wrong.

Three audiences read this document for different reasons:

- **Contributors writing Flutter code** use sections 1--3 to choose the
  correct token for every color, spacing value, radius, and text style.
  They use section 4 to verify accessibility requirements before
  submitting a PR. They use section 5 to understand which checks are
  automated and which require manual verification.

- **Designers using Claude Design or external tools** use section 1 to
  build mockups that map 1:1 to real tokens, section 2 to understand
  what a tenant can and cannot customize, and section 4 to design within
  the accessibility floor.

- **Customer-success engineers configuring a new tenant** use section 2
  as a step-by-step guide to creating a tenant branding directory, a
  `SoliplexColors` constant, and a flavor function. They do not need to
  read the rest unless they are debugging a visual issue.

---

## Section 1 --- Core primitives

Core primitives are invariant across tenants. A tenant cannot override a
primitive's structure --- only fill in its color and font slots via the
tenant theme surface (section 2). The primitives below define what *can*
be themed.

### 1.1 Color roles

Colors are defined in `lib/src/design/tokens/colors.dart` as the
`SoliplexColors` class. Each tenant provides a light and dark instance of
this class. The standard (Soliplex) tenant's values are
`lightSoliplexColors` and `darkSoliplexColors`.

Colors are accessed through two paths:

- **Material ColorScheme:** `Theme.of(context).colorScheme.*` --- for
  standard Material roles (primary, surface, error, etc.).
- **SoliplexTheme extension:** `SoliplexTheme.of(context).colors.*` ---
  for Soliplex-specific roles not in Material's ColorScheme.

| Role | Dart accessor (ColorScheme) | Dart accessor (SoliplexColors) | When to use |
| ---- | --------------------------- | ------------------------------ | ----------- |
| background | `colorScheme.surface` | `colors.background` | Page/scaffold background |
| foreground | `colorScheme.onSurface` | `colors.foreground` | Primary text on background |
| primary | `colorScheme.primary` | `colors.primary` | Brand accent, CTAs, active states |
| onPrimary | `colorScheme.onPrimary` | `colors.onPrimary` | Text/icons on primary surfaces |
| primaryContainer | `colorScheme.primaryContainer` | `colors.primaryContainer` | Subtle primary-tinted backgrounds |
| onPrimaryContainer | `colorScheme.onPrimaryContainer` | `colors.onPrimaryContainer` | Text on primaryContainer |
| secondary | `colorScheme.secondary` | `colors.secondary` | Secondary actions, less prominent than primary |
| onSecondary | `colorScheme.onSecondary` | `colors.onSecondary` | Text/icons on secondary surfaces |
| tertiary | `colorScheme.tertiary` | `colors.tertiary` | Tertiary accents, metadata, timestamps |
| onTertiary | `colorScheme.onTertiary` | `colors.onTertiary` | Text on tertiary surfaces |
| tertiaryContainer | `colorScheme.tertiaryContainer` | `colors.tertiaryContainer` | Subtle tertiary-tinted backgrounds |
| onTertiaryContainer | `colorScheme.onTertiaryContainer` | `colors.onTertiaryContainer` | Text on tertiaryContainer |
| accent | `colorScheme.surfaceDim` | `colors.accent` | Accent surface, emphasis backgrounds |
| onAccent | --- | `colors.onAccent` | Text on accent surfaces |
| muted | `colorScheme.secondaryContainer` | `colors.muted` | Disabled backgrounds, inactive chips |
| mutedForeground | `colorScheme.onSurfaceVariant` | `colors.mutedForeground` | Secondary text, placeholders |
| destructive | `colorScheme.error` | `colors.destructive` | Destructive actions, error states |
| onDestructive | `colorScheme.onError` | `colors.onDestructive` | Text/icons on destructive surfaces |
| errorContainer | `colorScheme.errorContainer` | `colors.errorContainer` | Subtle error backgrounds |
| onErrorContainer | `colorScheme.onErrorContainer` | `colors.onErrorContainer` | Text on errorContainer |
| border | --- | `colors.border` | Dividers, card borders, input borders |
| outline | `colorScheme.outline` | `colors.outline` | Higher-contrast outlines |
| outlineVariant | `colorScheme.outlineVariant` | `colors.outlineVariant` | Subtle outlines, blockquote borders |
| inputBackground | `colorScheme.surfaceContainer` | `colors.inputBackground` | Input fields, cards, selected tiles |
| hintText | --- | `colors.hintText` | Input hint/placeholder text |
| surfaceContainerLowest | `colorScheme.surfaceContainerLowest` | `colors.surfaceContainerLowest` | Lowest-emphasis container |
| surfaceContainerLow | `colorScheme.surfaceContainerLow` | `colors.surfaceContainerLow` | Low-emphasis container |
| surfaceContainerHigh | `colorScheme.surfaceContainerHigh` | `colors.surfaceContainerHigh` | High-emphasis container |
| surfaceContainerHighest | `colorScheme.surfaceContainerHighest` | `colors.surfaceContainerHighest` | Highest-emphasis container, code blocks |
| inversePrimary | `colorScheme.inversePrimary` | `colors.inversePrimary` | Inverted primary for contrast |
| link | --- | `colors.link` | Hyperlinks, tappable references |

**Semantic status colors** (to be added to `SoliplexColors` per Q3
decision):

| Role | When to use |
| ---- | ----------- |
| info | Informational banners, tooltips |
| warning | Warning banners, validation hints |
| danger | Critical alerts (distinct from destructive/error for non-action contexts) |
| success | Success banners, completion indicators |

These are currently defined in `lib/src/design/color/color_scheme_extensions.dart`
as a `SymbolicColors` extension using raw Material `Colors.*` values.
**Action required:** migrate these four roles into `SoliplexColors` so
tenants can override them.

**File:** `lib/src/design/tokens/colors.dart`

### 1.2 Typography ramp

Typography is defined in `lib/src/design/tokens/typography.dart` via
`soliplexTextTheme(SoliplexColors)`. All styles are parameterized by the
active color set.

| Style name | Font size | Weight | Line height | Dart accessor | When to use |
| ---------- | --------- | ------ | ----------- | ------------- | ----------- |
| headlineMedium | 28 | w400 | 1.3 | `textTheme.headlineMedium` | Page titles, hero text |
| titleLarge | 24 | w500 | 1.5 | `textTheme.titleLarge` | Section headings, markdown h1 |
| titleMedium | 20 | w500 | 1.5 | `textTheme.titleMedium` | Sub-section headings, markdown h2 |
| titleSmall | 16 | w500 | 1.5 | `textTheme.titleSmall` | Card titles, markdown h3 |
| bodyLarge | 18 | w400 | 1.5 | `textTheme.bodyLarge` | Emphasized body text |
| bodyMedium | 16 | w400 | 1.5 | `textTheme.bodyMedium` | Default body text, input text |
| bodySmall | 13 | w400 | 1.5 | `textTheme.bodySmall` | Captions, metadata, timestamps |
| labelMedium | 16 | w500 | 1.5 | `textTheme.labelMedium` | Button labels, badge text |
| labelSmall | 12 | w500 | 1.5 | `textTheme.labelSmall` | Small labels, annotations |

**Monospace:** `context.monospace` (via `TypographyX` extension in
`lib/src/design/tokens/typography_x.dart`) returns a platform-aware
monospace `TextStyle`: SF Mono on Apple platforms, Roboto Mono elsewhere.
All widgets needing monospace text must use this accessor instead of
constructing inline `TextStyle` values.

**File:** `lib/src/design/tokens/typography.dart`,
`lib/src/design/tokens/typography_x.dart`

### 1.3 Spacing scale

Spacing is defined in `lib/src/design/tokens/spacing.dart` as
`SoliplexSpacing`. Use these constants for all `EdgeInsets`, `SizedBox`,
`Padding`, and gap values. Do not use bare numeric literals for spacing.

| Token | Value (dp) | Dart accessor | When to use |
| ----- | ---------- | ------------- | ----------- |
| s1 | 4 | `SoliplexSpacing.s1` | Tight spacing: chip padding, icon gaps |
| s2 | 8 | `SoliplexSpacing.s2` | Default inner padding, small gaps |
| s3 | 12 | `SoliplexSpacing.s3` | Medium padding, card content insets |
| s4 | 16 | `SoliplexSpacing.s4` | Standard section padding, list item padding |
| s5 | 20 | `SoliplexSpacing.s5` | Extended padding for emphasis **[to be added]** |
| s6 | 24 | `SoliplexSpacing.s6` | Large separation between sections |
| s8 | 32 | `SoliplexSpacing.s8` | Extra-large separation, page margins **[to be added]** |

**Action required:** Add `s5 = 20` and `s8 = 32` to `SoliplexSpacing`.

**File:** `lib/src/design/tokens/spacing.dart`

### 1.4 Border radius scale

Border radii are defined in `lib/src/design/tokens/radii.dart` as
`SoliplexRadii`. The token scale must be realigned to match actual usage
(per Q2 decision). The canonical scale is:

| Token | Value (dp) | Dart accessor | When to use |
| ----- | ---------- | ------------- | ----------- |
| xs | 4 | `soliplexRadii.xs` | Inline code, small badges, tight corners **[to be added]** |
| sm | 8 | `soliplexRadii.sm` | Default card corners, code blocks, containers **[to be realigned from 6]** |
| md | 12 | `soliplexRadii.md` | Buttons, inputs, tiles, dialogs (unchanged) |
| lg | 16 | `soliplexRadii.lg` | Large cards, modals (unchanged) |
| xl | 24 | `soliplexRadii.xl` | Hero surfaces, sheets (unchanged) |

**Action required:** Add `xs = 4`, change `sm` from 6 to 8. The
`soliplexRadii` constant and all `BorderRadius.circular(...)` calls
referencing these values must be updated.

**File:** `lib/src/design/tokens/radii.dart`

### 1.5 Motion

**Action required:** Create `lib/src/design/tokens/motion.dart` with
duration and curve tokens. No motion tokens exist today. The following
scale is recommended based on Material 3 conventions:

| Token | Value | Dart accessor | When to use |
| ----- | ----- | ------------- | ----------- |
| durationShort | 150ms | `SoliplexMotion.durationShort` | Micro-interactions: button press, icon swap **[to be created]** |
| durationMedium | 300ms | `SoliplexMotion.durationMedium` | Standard transitions: expand/collapse, fade **[to be created]** |
| durationLong | 500ms | `SoliplexMotion.durationLong` | Complex transitions: page enter, sheet slide **[to be created]** |
| curveStandard | `Curves.easeInOut` | `SoliplexMotion.curveStandard` | Default easing for most animations **[to be created]** |
| curveDecelerate | `Curves.easeOut` | `SoliplexMotion.curveDecelerate` | Elements entering the screen **[to be created]** |
| curveAccelerate | `Curves.easeIn` | `SoliplexMotion.curveAccelerate` | Elements leaving the screen **[to be created]** |

**File:** `lib/src/design/tokens/motion.dart` (to be created)

### 1.6 Elevation scale

Elevation is currently set uniformly to 0 across all Material widget
themes (cards, buttons, expansion tiles). This is intentional --- the
design relies on border and background color for visual hierarchy, not
shadow.

| Token | Value | When to use |
| ----- | ----- | ----------- |
| none | 0 | All surfaces (current default) |

If additional elevation levels become necessary, they will be added here.

### 1.7 Breakpoints

Breakpoints are defined in `lib/src/design/tokens/breakpoints.dart` as
`SoliplexBreakpoints`.

| Token | Value (dp) | Dart accessor | When to use |
| ----- | ---------- | ------------- | ----------- |
| mobile | 320 | `SoliplexBreakpoints.mobile` | Minimum supported width |
| tablet | 600 | `SoliplexBreakpoints.tablet` | Narrow-to-wide layout switch |
| desktop | 840 | `SoliplexBreakpoints.desktop` | Full desktop layout with sidebars |

Layout rules:

- Below `tablet` (600): single-column layout, no sidebars.
- Between `tablet` and `desktop` (600--840): transitional, sidebars
  may appear as overlays.
- At or above `desktop` (840): full multi-column layout with persistent
  sidebars.

**File:** `lib/src/design/tokens/breakpoints.dart`

---

## Section 2 --- Tenant theming surface

### 2.1 Overview

The Soliplex frontend is white-label. Each tenant is a build-time flavor
that provides branding assets and a `SoliplexColors` constant. Tenants
do not switch at runtime; the flavor is selected at build time and
compiled into the binary.

### 2.2 Tenant directory schema

Each tenant has a directory under `assets/branding/<tenant>/` and a
corresponding flavor function in `lib/src/flavors/<tenant>.dart`.

```text
assets/branding/<tenant>/
  app_icon_1024.png        # Required. App icon, 1024x1024 PNG.
  logo_1024.png            # Required. Logo mark, 1024x1024 PNG.
  logo.svg                 # Required. Vector logo for in-app display.
  favicon_48.png           # Required. Web favicon, 48x48 PNG.
  logo_splash_android12.png # Required. Android 12+ splash, 1152x1152 PNG.
```

All five image assets are required. Additional assets (e.g., dark-mode
logo variants, custom fonts) are optional and must be documented in a
`README.md` within the tenant directory if present.

### 2.3 Color definition

Each tenant provides light and dark `SoliplexColors` constants in a
per-tenant Dart file. The canonical location is:

```text
lib/src/flavors/<tenant>_colors.dart
```

The file must export two `const SoliplexColors` values:

- `light<Tenant>Colors`
- `dark<Tenant>Colors`

Every field on `SoliplexColors` must be provided. There are no defaults
--- a missing field is a compile error.

### 2.4 Flavor function

Each tenant provides a flavor function in `lib/src/flavors/<tenant>.dart`
that mirrors the structure of `lib/src/flavors/standard.dart`. The flavor
function:

1. References the tenant's color constants.
2. Constructs `ThemeData` via `soliplexLightTheme(colors: ...)` (and
   `soliplexDarkTheme(colors: ...)` once dark mode is implemented).
3. Adds the `MarkdownThemeExtension`.
4. References the tenant's logo asset.
5. Composes the same module set as the standard flavor (unless the
   tenant requires module additions/exclusions).

### 2.5 Worked example: Soliplex default tenant

```text
assets/branding/soliplex/
  app_icon_1024.png
  logo_1024.png
  logo.svg
  favicon_48.png
  logo_splash_android12.png

lib/src/design/tokens/colors.dart
  -> lightSoliplexColors (30 fields)
  -> darkSoliplexColors (30 fields)

lib/src/flavors/standard.dart
  -> standard() async => ShellConfig(
       theme: soliplexLightTheme(colors: lightSoliplexColors),
       logo: Image.asset('assets/branding/soliplex/logo_1024.png', ...),
       ...
     )
```

### 2.6 Fallback rules

- **Missing asset file:** The build will fail at `flutter build` if a
  declared asset path does not resolve. There is no runtime fallback.
- **Missing color field:** Compile error. `SoliplexColors` requires all
  30 fields (plus info/warning/danger/success once Q3 migration is
  complete).
- **Missing flavor function:** No fallback. The app entry point must
  reference a specific flavor.

### 2.7 What tenants cannot override

The following are core primitives that no tenant manifest may change:

| Primitive | Rationale |
| --------- | --------- |
| Spacing scale (values) | Consistent spatial rhythm across tenants prevents layout breakage |
| Border radius scale (values) | Consistent corner language across tenants |
| Breakpoint thresholds | Responsive behavior must be predictable for QA |
| Typography ramp (sizes, weights, line heights) | Accessibility and readability guarantees |
| Minimum touch target (48dp) | Accessibility floor (section 4) |
| Motion durations and curves | Consistent interaction feel |
| Elevation scale | Consistent depth language |

Tenants **can** override:

- All color roles in `SoliplexColors`
- Font family (by providing custom fonts in the branding directory and
  referencing them in the flavor's `ThemeData`)
- Logo and icon assets
- App name

### 2.8 Build configuration

Each tenant must update the following in `pubspec.yaml` or a
tenant-specific pubspec overlay:

- `flutter.assets` --- add `assets/branding/<tenant>/`
- `flutter_launcher_icons.image_path` --- point to tenant icon
- `flutter_native_splash.image` --- point to tenant logo
- `flutter_native_splash.color` --- tenant splash background color

---

## Section 3 --- Components

No public widgets are exported from the workspace packages
(`packages/*/lib/`). All four packages (`soliplex_agent`,
`soliplex_client`, `soliplex_client_native`, `soliplex_logging`) are
pure Dart with no Flutter dependency.

All 57 widget classes live in the main `lib/` directory. The components
below are the shared/reusable widgets identified by the audit. Module-
specific screen widgets are not documented here individually --- they
must follow the rules in sections 1 and 4.

### 3.1 CopyButton

**Location:** `lib/src/shared/copy_button.dart`

**Contract:** A button that copies text to the clipboard and shows
transient feedback (success/error).

| Parameter | Type | Required | Default |
| --------- | ---- | :------: | ------- |
| text | `String` | Yes | --- |
| tooltip | `String` | No | `'Copy'` |

**Interaction states:**

| State | Visual treatment |
| ----- | ---------------- |
| Default | Icon button with `colorScheme.onSurfaceVariant` foreground |
| Hover | Material hover overlay |
| Pressed | Icon swaps to check mark for 2 seconds |
| Error | Icon swaps to error icon briefly |

**Accessibility:**

- Wraps content in `Semantics(button: true, label: tooltip)`.
- Touch target: inherits `IconButton` default (48dp).

**Golden test:** **TBD --- no golden tests exist yet.**

**Tenant-overridable:** Icon color follows `colorScheme`, so it
inherits the tenant's color scheme automatically.

### 3.2 FeedbackButtons

**Location:** `lib/src/modules/room/ui/feedback_buttons.dart`

**Contract:** Thumbs-up and thumbs-down buttons for message feedback.

**Accessibility:**

- Each button wrapped in `Semantics(button: true, label: tooltip)`.
- Touch target: inherits `IconButton` default (48dp).

**Golden test:** **TBD --- no golden tests exist yet.**

### 3.3 CodeBlockBuilder

**Location:** `lib/src/modules/room/ui/markdown/code_block_builder.dart`

**Contract:** Renders fenced code blocks in markdown output with syntax
highlighting and a copy button.

**Accessibility:**

- Wraps in `Semantics(label: 'Code block')` or
  `Semantics(label: 'Code block in {language}')`.
- SVG code blocks: `Semantics(label: 'SVG image')`.

**Golden test:** **TBD --- no golden tests exist yet.**

### 3.4 HttpStatusDisplay

**Location:** `lib/src/modules/diagnostics/ui/http_status_display.dart`

**Contract:** Displays HTTP status code with color-coded badge.

**Accessibility:**

- `Semantics(label: group.statusDescription)` with `ExcludeSemantics`
  on decorative child.

**Golden test:** **TBD --- no golden tests exist yet.**

### 3.5 HttpEventTile

**Location:** `lib/src/modules/diagnostics/ui/http_event_tile.dart`

**Contract:** Displays a single HTTP request/response event in the
network inspector.

**Accessibility:**

- `Semantics(label: group.semanticLabel)`.

**Golden test:** **TBD --- no golden tests exist yet.**

### 3.6 All other widgets

The remaining 52 widget classes (screens, tiles, inputs, panels) are
module-internal. They are not documented individually here but must:

1. Use only named tokens from section 1 for all colors, spacing, radii,
   typography, and motion.
2. Meet the accessibility floor in section 4.
3. Respond to breakpoints per section 1.7.

**Golden tests:** **TBD --- no golden tests exist for any widget.**

---

## Section 4 --- Accessibility floor

The following accessibility commitments apply to every component, every
theme, and every tenant. Tenants cannot configure these away.

### 4.1 WCAG conformance

Target: **WCAG 2.2 Level AA**. This is the minimum. Individual
components may exceed AA where practical.

### 4.2 Text contrast ratios

| Text category | Minimum contrast ratio (against background) |
| ------------- | ------------------------------------------- |
| Normal text (< 18sp, or < 14sp bold) | 4.5:1 |
| Large text (>= 18sp, or >= 14sp bold) | 3:1 |
| UI components and graphical objects | 3:1 |

Every tenant color set must be validated against these ratios before
release. **TBD --- no automated contrast checking exists yet.** Manual
verification is required for each tenant's light and dark palettes.

### 4.3 Minimum touch targets

All interactive elements must have a minimum touch target of
**48 x 48 dp**. This applies to:

- Buttons (icon, text, filled, outlined)
- List tiles and tappable cards
- Custom `GestureDetector` and `InkWell` wrappers
- Form inputs

Do not use `constraints: const BoxConstraints()` or
`VisualDensity.compact` on interactive elements without ensuring the
resulting touch target still meets 48dp.

**Known violations (from audit):**

- `room_screen.dart:757-759` --- close icon with zero constraints
- `upload_event_banner.dart:276-283` --- close icon with zero constraints
- `room_info_screen.dart:564-566` --- compact density buttons
- `request_detail_view.dart:223,231` --- 32x32 tab buttons

### 4.4 Keyboard navigation

- All interactive elements must be reachable via Tab key.
- Focus order must follow visual reading order (left-to-right,
  top-to-bottom).
- Focus indicators must be visible (Flutter's default focus ring is
  acceptable).
- Modal dialogs must trap focus within the dialog.

**TBD --- no keyboard navigation tests exist yet.**

### 4.5 Screen reader expectations

- Every interactive element must have a `Semantics` label or a `tooltip`
  that conveys its purpose.
- Decorative elements must be excluded from the semantics tree
  (`ExcludeSemantics` or `Semantics(excludeSemantics: true)`).
- AG-UI streaming surfaces (message timeline, loading tiles) must use
  `Semantics(liveRegion: true)` so screen readers announce new content.
  **TBD --- no live-region semantics exist yet.**
- Citation readback: when a citation is expanded, its content must be
  announced. **TBD --- not implemented.**
- Announcement throttling: streaming text should not overwhelm the
  screen reader. Batch announcements at sentence boundaries or on a
  debounce timer. **TBD --- not implemented.**

**Current coverage:** 5 components have explicit `Semantics` wrapping.
26 files use `tooltip:` on `IconButton`. All other interactive elements
lack semantic labels.

### 4.6 Reduced motion

- When the platform's "reduce motion" accessibility setting is enabled,
  all animations must either be disabled or reduced to instant
  transitions.
- Check via `MediaQuery.disableAnimations` or
  `MediaQuery.of(context).disableAnimations`.

**TBD --- no reduced motion handling exists yet.**

---

## Section 5 --- Verification

### 5.1 Lint rules

**TBD --- `packages/soliplex_lints/` does not exist yet.** Once created
by the `design-system-enforce` skill, the following rules should be
enforced:

| Rule | What it checks |
| ---- | -------------- |
| `no_hardcoded_colors` | No `Color(0x...)`, `Colors.*` outside token files |
| `no_hardcoded_spacing` | No bare numeric literals in `EdgeInsets`, `SizedBox`, `Padding` |
| `no_hardcoded_radii` | No `BorderRadius.circular(N)` --- must use `soliplexRadii.*` |
| `no_inline_textstyle` | No `TextStyle(...)` construction outside token files --- use `textTheme.*` or `context.monospace` |
| `require_semantics_label` | Interactive widgets must have a `Semantics` wrapper or `tooltip` |
| `min_touch_target` | `BoxConstraints` on interactive elements must allow >= 48dp |

### 5.2 Golden tests

**TBD --- zero golden tests exist.** Golden tests should be created for
every component listed in section 3, covering:

- Default state in light theme
- Default state in dark theme (once implemented)
- Each interaction state (hover, focus, pressed, disabled, error)
- Each breakpoint (mobile, tablet, desktop) for responsive widgets

Golden test files should live at `test/golden/<module>/<widget>_test.dart`.

### 5.3 Accessibility tests

**TBD --- zero Semantics-asserting tests exist.** Each widget test
should include:

- `find.bySemanticsLabel()` assertions for all interactive elements
- Touch target size assertions (minimum 48dp)
- Focus order assertions for complex layouts

### 5.4 CI coverage

Current CI (`.github/workflows/flutter.yaml`) runs:

- **lint** --- dart format, flutter analyze, dart doc, markdown lint
- **test** --- app and package tests with 80% coverage threshold
- **build-web** --- web release build

**TBD --- CI does not yet run:**

- Golden test comparison
- Accessibility audits
- Contrast ratio validation for tenant color sets
- Per-tenant build verification

### 5.5 Release verification ritual

**TBD --- the `release-verification` skill does not exist yet.** When
created, it should verify:

1. All lint rules pass (zero warnings).
2. All golden tests match their baselines.
3. All Semantics assertions pass.
4. Contrast ratios for every tenant's light and dark palette meet WCAG AA.
5. Every tenant's branding directory contains all required assets.
6. Every tenant's flavor function builds successfully.

---

## Section 6 --- Change process

### 6.1 Core primitive changes (high blast radius)

Changes to tokens in `lib/src/design/tokens/` affect every component and
every tenant. Process:

1. Open a GitHub issue describing the change and rationale.
2. Draft the change in a branch. Run the full test suite including
   golden tests (once they exist) to identify visual regressions.
3. Update this document (`visual-design.md`) with the new token values.
4. Update `decisions.md` with the decision record.
5. Request review from at least one other contributor.
6. Merge. All tenants pick up the change on their next build.

### 6.2 Tenant theme changes (single tenant)

Changes to a single tenant's colors, assets, or flavor function. Process:

1. Modify files under `assets/branding/<tenant>/` and/or
   `lib/src/flavors/<tenant>*.dart`.
2. Run golden tests for the affected tenant (once they exist).
3. Verify contrast ratios for the updated palette.
4. Standard PR review. No update to this document required unless the
   change reveals a gap in the theming surface.

### 6.3 Component additions

New shared widgets added to `lib/src/shared/` or promoted from a module.
Process:

1. Implement the widget following the contract template in section 3.
2. Add golden tests for all states and breakpoints.
3. Add Semantics assertions.
4. Add an entry to section 3 of this document.
5. Standard PR review.

### 6.4 Deprecation and breaking changes

If a token, component, or theming surface is removed or renamed:

1. Mark as `@Deprecated('Use X instead')` in code.
2. Note in this document with the deprecation date.
3. Remove after one release cycle (all tenants must migrate).

---

## Appendix A --- Decision log

**Source audit:** `docs/design-system/audit-2026-04-22.md`

**Reconciliation:** Reconciled against audit-2026-04-22.md Section 7:
10/10 questions answered.

**Decision date:** 2026-04-22

**Decision-makers:** Team (recorded in `docs/design-system/decisions.md`)

---

### Q1. Missing spacing tokens

> Should `SoliplexSpacing` be extended with s5=20 and s8=32, or should
> the usages be consolidated to existing values?

**Answer:** Yes. Add `s5 = 20` and `s8 = 32` to `SoliplexSpacing`.

### Q2. Border radius mismatch

> The most common border radii in widget code (4 and 8) do not
> correspond to any named `SoliplexRadii` token. Meanwhile, `sm=6` and
> `lg=16` / `xl=24` are rarely referenced. Should the token scale be
> realigned to match actual usage?

**Answer:** Yes. Add `xs = 4`, change `sm` from 6 to 8. Keep `md = 12`,
`lg = 16`, `xl = 24`.

### Q3. SymbolicColors uses Material palette directly

> The info/warning/danger/success getters in
> `color_scheme_extensions.dart` return `Colors.blue`, `Colors.green`,
> etc. Should these become fields on `SoliplexColors` for tenant
> overridability?

**Answer:** Yes. Migrate info, warning, danger, success into
`SoliplexColors` fields.

### Q4. Unused `context.monospace` extension

> `typography_x.dart` defines a platform-aware monospace helper, but no
> widget references it. Should this be canonized and adopted, or removed?

**Answer:** Canonized and adopted. All widgets needing monospace text
must use `context.monospace` instead of constructing inline `TextStyle`
values.

### Q5. Single-tenant reality

> What is the expected timeline for a second tenant, and should the
> design system accommodate runtime tenant switching or only build-time
> flavors?

**Answer:** Second and additional tenants will be immediate. The design
system should accommodate build-time tenant branding (not runtime
switching).

### Q6. Color manifest format

> If tenants need to provide their own palettes, should colors move to a
> JSON/YAML manifest loaded at runtime, or stay as compile-time constants
> in per-tenant Dart files?

**Answer:** Stay as compile-time constants in per-tenant Dart files.

### Q7. Dark theme completeness

> `darkSoliplexColors` exists but `soliplexDarkTheme()` does not. Is
> dark mode a near-term priority, or is the dark palette aspirational?

**Answer:** Dark mode is a near-term priority. A `soliplexDarkTheme()`
function must be created following the same pattern as
`soliplexLightTheme()`.

### Q8. No motion tokens

> Is consistent motion a design goal?

**Answer:** Yes. Create `lib/src/design/tokens/motion.dart` with
duration and curve tokens.

### Q9. Diagnostics module styling

> The diagnostics module has the highest density of inline `TextStyle`
> and `EdgeInsets` constructions. Is this module considered part of the
> design system surface, or is it an internal developer tool exempt from
> token discipline?

**Answer:** It is part of the design system and is not exempt from
token discipline. All inline constructions must be migrated to use
named tokens.

### Q10. `SectionCard` scope

> The `SectionCard` widget in `room_info_widgets.dart` is the most
> reusable container pattern but is scoped to the room module. Should it
> be promoted to `lib/src/shared/` or the design system layer?

**Answer:** No, leave it as is. `SectionCard` stays in the room module.

---

## Next steps

### TBDs ranked by downstream impact

1. **Motion tokens (section 1.5)** --- blocks any animation
   standardization. Create `lib/src/design/tokens/motion.dart`.
   *Blocks: enforcement lint for motion consistency.*

2. **Spacing token additions (section 1.3)** --- `s5` and `s8` must
   exist before lints can flag bare `20` and `32` literals.
   *Blocks: `no_hardcoded_spacing` lint rule.*

3. **Border radius realignment (section 1.4)** --- add `xs`, change
   `sm` from 6 to 8, then migrate all `BorderRadius.circular(4)` and
   `BorderRadius.circular(8)` calls.
   *Blocks: `no_hardcoded_radii` lint rule.*

4. **Semantic status colors migration (section 1.1)** --- move
   info/warning/danger/success from `SymbolicColors` extension into
   `SoliplexColors` fields.
   *Blocks: tenant overridability of status colors.*

5. **`context.monospace` adoption (section 1.2)** --- migrate all inline
   monospace `TextStyle` constructions to use `context.monospace`.
   *Blocks: `no_inline_textstyle` lint rule for monospace.*

6. **Dark theme function (Q7)** --- create `soliplexDarkTheme()`.
   *Blocks: dark mode support, dark golden tests.*

7. **Golden tests (section 5.2)** --- create golden tests for all
   section 3 components.
   *Blocks: visual regression safety net.*

8. **Live-region semantics (section 4.5)** --- add `Semantics(liveRegion: true)`
   to streaming surfaces.
   *Blocks: screen reader usability for chat.*

9. **Touch target fixes (section 4.3)** --- fix the four known
   undersized touch targets.
   *Blocks: WCAG AA compliance.*

10. **Lint package creation (section 5.1)** --- create
    `packages/soliplex_lints/` with the rules listed in section 5.1.
    *Blocks: automated enforcement of all token rules.*

Once items 1--5 are resolved, run **`design-system-enforce`** to create
the lint package and automated checks.
