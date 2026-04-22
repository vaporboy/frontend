---
name: design-system-audit
description: Use this skill when the user asks for a baseline of the current design system, wants to discover what tokens and components actually exist in the code, or needs a starting picture of the multi-tenant theming surface before any styleguide is written. Triggers on phrases like "audit the design system", "baseline the styleguide", "what's the current state", "where are tokens leaking", or "what does the design system look like today". Do NOT use this skill to write the styleguide itself or to fix drift — those are separate skills (design-system-synthesize and design-system-enforce) that run after this audit.
---

# Design System Audit

You are auditing the Soliplex Frontend repository to produce a baseline
report describing what the design system currently is, as practiced in code.
There is no prior styleguide in this repo. Your job is **pure discovery** —
not gap analysis, not recommendations for fixes, not opinions on what the
system should become. Those decisions are downstream and will be informed
by this report.

**Do not modify any source files during this audit.** The deliverable is a
single markdown report.

## Context the auditor must load first

Before producing anything, read these in order:

1. `CLAUDE.md` and `AGENTS.md` at the repo root — operating guidance.
2. `pubspec.yaml` and every `packages/*/pubspec.yaml` — the workspace shape.
3. `analysis_options.yaml` — current static analysis posture.
4. `lib/` top-level files — the app entry points and shared theming.
5. `packages/*/lib/` — the importable component library, especially anything
   under a `theme/`, `tokens/`, `components/`, or `widgets/` subdirectory.
6. `assets/branding/` — every tenant subdirectory. Each one is a brand
   identity the design system must support.
7. Any docs under `docs/` that describe visual design, branding,
   accessibility, or component contracts.
8. The `nginx/` directory — note any tenant-aware path rewrites that affect
   asset resolution at runtime.

## Multi-tenant ground truth

The repo is white-label. Treat the design system as three layers:

- **Core primitives** — tokens, spacing scale, motion, typography ramp, and
  component APIs that are constant across every tenant.
- **Tenant theme** — colors, fonts, logos, and any tenant-specific overrides
  loaded from `assets/branding/<tenant>/`.
- **Component implementations** — widgets that consume both layers and must
  never bake tenant-specific values into their source.

Note in the report which layer each finding belongs to. A finding that
crosses layers (e.g., a tenant color hardcoded inside a component) is
inherently more significant than one contained within a single layer, but
do not editorialize beyond that classification.

## Audit deliverable

Produce `docs/design-system/audit-YYYY-MM-DD.md` with these sections,
in order.

### 1. Inventory

A markdown table listing every file Claude treats as part of the design
system, classified by layer (Core / Tenant / Component / Doc / Other) with
file path, brief purpose, and last-modified date.

### 2. Tenant matrix

A table with one row per tenant under `assets/branding/`. Columns: tenant
name, asset categories present (logo, color manifest, fonts, etc.), asset
categories absent, any tenant-specific code paths (greppable references in
`lib/` or `packages/`), any tenant-specific deployment hints from
`nginx/`.

### 3. Token discipline (current state)

Find every hardcoded `Color(0x...)`, `Color.fromARGB`, inline
`TextStyle(...)` construction, and `EdgeInsets`/`SizedBox` literal greater
than 4 that appears anywhere in `lib/` or `packages/*/lib/`. For each,
record file, line, snippet. Group by file. Do not propose tokens — that's
synthesis work. Just catalogue what's there.

Also catalogue what *does* live in approved-looking locations: any file
under a `theme/` or `tokens/` subdirectory should be summarized (what
constants/classes/extensions does it export?).

### 4. Component coverage

For each public widget exported from `packages/*/lib/`, note whether it
has a golden test under `packages/*/test/golden/` and whether its tests
assert any Semantics coverage. Render as a coverage matrix. Empty cells
are observations, not failures.

### 5. Accessibility baseline (current state)

Walk every Screen-level widget under `lib/` and report: missing Semantics
labels on interactive elements, touch targets under 48dp, any AG-UI
streaming surfaces that lack live-region semantics for screen readers.
Flag any text-on-background combinations that cannot be verified
statically.

### 6. Implicit conventions

Walk the codebase looking for patterns that show up repeatedly without
being formalized: naming conventions for theme extensions, recurring
widget composition patterns, recurring color or spacing values that
appear identically across many files (these are *de facto* tokens
waiting to be named). List them — they are the seed for the synthesis
step.

### 7. Open questions

A list of decisions the team must make before any styleguide can be
written. Examples: "There are 17 distinct gray values in use — is this
intentional or should the palette be consolidated?" "Both `Spacing` and
`AppSpacing` are referenced — which is canonical?" "Tenant `bespin/` has
a custom font but no fallback declaration — is the fallback the Soliplex
default?" Be specific; vague questions don't move the team forward.

## What this skill must not do

- Modify any source files.
- Propose a styleguide structure or write any of its contents.
- Make tenant-specific design decisions.
- Recommend specific fixes to drift findings.
- Run `flutter test`, `flutter build`, or any command that would alter
  generated files or coverage reports.

## When the audit finishes

End the report with a "Next steps" section that names the two follow-up
skills to invoke once the team has reviewed:

- `design-system-synthesize` — drafts the first version of
  `docs/design-system/visual-design.md` from the audit findings plus
  team decisions on the open questions in section 7.
- `design-system-enforce` — extends `packages/soliplex_lints/` with
  rules tied to the canonical tokens defined by the synthesis step.
