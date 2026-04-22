---
name: design-system-synthesize
description: Use this skill after design-system-audit has produced a baseline report AND the team has answered the open questions in section 7 of that report. This skill drafts the first version of docs/design-system/visual-design.md, structured for the multi-tenant white-label architecture. Triggers on "draft the styleguide", "write visual-design.md from the audit", or "synthesize the design system doc". Do NOT use this skill if the audit has not been run, if the team has not made decisions on open questions, or if the user wants to enforce rules in code (that's design-system-enforce).
---

# Design System Synthesis

You are drafting the first version of `docs/design-system/visual-design.md`
for the Soliplex Frontend repository, using the most recent
`docs/design-system/audit-*.md` report as the primary source and the
team's answers to that audit's "Open questions" section as decision input.

This is the styleguide that every future Claude session, every white-label
customer, and every release-verification check will treat as canonical.
Get it right.

## Required inputs before you begin

Before writing anything, confirm all three are available:

1. The latest audit report under `docs/design-system/audit-*.md`. If there
   is more than one, use the most recent.
2. A separate file or chat input from the team containing answers to every
   "Open questions" item in the audit. If any are unanswered, **stop and
   list them** rather than guessing.
3. Read `CLAUDE.md`, `AGENTS.md`, and the current state of
   `assets/branding/` so the doc reflects the actual tenant set.

## Architectural commitments the doc must reflect

The styleguide is structured around the three-layer model the audit
established:

- **Core primitives** are invariant across tenants. A tenant cannot
  override a primitive; the primitive defines what *can* be themed.
- **Tenant theme** is the override surface. Every tenant theme is a
  declarative manifest under `assets/branding/<tenant>/`.
- **Component contracts** describe what each component must do regardless
  of theme — including accessibility floors, interaction states, and
  responsive behavior.

Write the doc as if a developer onboarding tomorrow has never seen the
codebase. Assume nothing.

## Document structure

Produce `docs/design-system/visual-design.md` with these sections, in
order. Do not add sections beyond these without flagging it.

### Section 0 — How to use this document

Two paragraphs. Who reads this doc, when they read it, and what they're
expected to do with it. Distinguish three audiences explicitly:
contributors writing Flutter code, designers using Claude Design or
external tools, and customer-success engineers configuring a new tenant.

### Section 1 — Core primitives

For each primitive category — color roles, typography ramp, spacing
scale, motion durations, motion curves, border radius scale, elevation
scale, breakpoints — provide:

- The complete enumeration of values, named.
- The Dart accessor (e.g., `Theme.of(context).colorScheme.primary`,
  `Spacing.md`, `Motion.standard`).
- The file in `lib/theme/` or `packages/*/lib/theme/` where the primitive
  is defined.
- A one-sentence rule for when to use each value.

If the audit's section 6 ("Implicit conventions") surfaced de facto
tokens that the team decided to formalize, name them here.

### Section 2 — Tenant theming surface

A precise specification of what a tenant manifest may override and what
it may not. Include:

- The schema of `assets/branding/<tenant>/` — every file that may appear,
  every key that may appear inside those files, every required field
  versus optional.
- A worked example showing the Soliplex default tenant manifest in full.
- The fallback rules — what happens when a tenant manifest is missing a
  field, references a missing asset, or declares a value outside the
  allowed range.
- The list of primitives that *cannot* be themed and the rationale for
  each (typically accessibility floors and brand-neutral interaction
  affordances).

### Section 3 — Components

One subsection per public widget exported from `packages/*/lib/`. Each
subsection covers:

- The component's contract — what it does, what it does not do.
- Its required and optional parameters, with type and default.
- Its interaction states (default, hover, focus, pressed, disabled, error)
  and the visual treatment of each in terms of the primitives in section 1.
- Its accessibility requirements — semantics role, label sources, focus
  order behavior, minimum touch target.
- Its responsive behavior across the breakpoints in section 1.
- A reference to its golden test file under `packages/*/test/golden/`.
- Any tenant-overridable surface (typically only color slots), referencing
  the keys in section 2.

If a component lacks any of the above, mark it `**TBD**` rather than
inventing. The follow-up enforcement skill will flag every TBD.

### Section 4 — Accessibility floor

The minimum accessibility commitments that apply across all components,
all themes, all tenants. Cover at minimum:

- WCAG conformance level (state explicitly which version and level).
- Section 508 conformance posture if relevant.
- Minimum text contrast ratios per text size category.
- Minimum touch target dimensions.
- Keyboard navigation expectations.
- Screen reader expectations, including AG-UI streaming surfaces
  (live-region usage, announcement throttling, readback of citations).
- Reduced motion handling.

Tenants cannot configure these away. State this explicitly.

### Section 5 — Verification

Describe how each rule in this document is checked, who checks it, and
when. Include:

- Which lints in `packages/soliplex_lints/` enforce which token rules.
- Which golden tests cover which components.
- Which widget tests cover which accessibility commitments.
- Which platform-tenant combinations are exercised in CI.
- The release-verification ritual (link to the eventual
  `release-verification` skill once it exists).

If a rule has no automated check, state that explicitly. Manual gates
are valid; undocumented manual gates are not.

### Section 6 — Change process

How an addition, deprecation, or breaking change to the design system is
proposed, reviewed, and shipped. Distinguish core-primitive changes
(high blast radius, all tenants) from tenant-theme changes
(single tenant) from component additions (review against the contract
template).

### Appendix A — Decision log

A reverse-chronological list of decisions the team has made about the
design system, with date, the question (often pulled from an audit's
"Open questions" section), and the answer. This is the artifact that
explains *why* the doc says what it says, six months from now when
nobody remembers the meeting.

Seed this with the answers to the most recent audit's open questions.

## What this skill must not do

- Invent values not present in the audit or the team's decisions.
- Skip sections by declaring them "out of scope" — every section above
  is mandatory; if the input doesn't support a section, write the
  section with `**TBD — pending [specific decision]**` placeholders.
- Modify lint rules, theme files, or any code under `lib/` or
  `packages/*/lib/`. Code changes are downstream of the styleguide,
  not the other way around.
- Generate the release-verification skill. That comes after the
  enforcement layer has stabilized for at least one release.

## When the synthesis finishes

End the document with a "Next steps" section listing every TBD by
section, ranked by how much it blocks downstream work. Then recommend
the team run `design-system-enforce` once the high-priority TBDs are
resolved.
