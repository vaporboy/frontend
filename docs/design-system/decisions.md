# Design System Decisions

**Answers to:** docs/design-system/audit-2026-04-22.md, Section 7
**Decided:** 2026-04-22
**Decided by:** EK, AR, JJ
**Status:** Authoritative until superseded

## 1. Missing spacing tokens

> Should SoliplexSpacing be extended with s5=20 and s8=32?

Yes.

## 2. Border radius mismatch

> Should the token scale be realigned to match actual usage?

Yes.

## 3. SymbolicColors uses Material palette directly

> Should these become fields on SoliplexColors for tenant overridability?

Yes.

## 4. Unused context.monospace extension

> Should this be canonized and adopted, or removed?

Canonized and adopted.

## 5. Single-tenant reality

> What is the expected timeline for a second tenant, and should the
> design system accommodate runtime tenant switching or only build-time
> flavors?

Second and additional tenants will be immediate; the design system should
accommodate build-time tenant branding.

## 6. Color manifest format

> If tenants need to provide their own palettes, should colors move to a
> JSON/YAML manifest loaded at runtime, or stay as compile-time constants
> in per-tenant Dart files?

Stay as compile-time constants in per-tenant Dart files.

## 7. Dark theme completeness

> Is dark mode a near-term priority, or is the dark palette aspirational?

Dark mode is a near-term priority.

## 8. No motion tokens

> Is consistent motion a design goal?

Yes.

## 9. Diagnostics module styling

> Is the diagnostics module part of the design system surface, or is it
> an internal developer tool exempt from token discipline?

It is part of the design system and is not exempt from token discipline.

## 10. SectionCard scope

> Should SectionCard be promoted to lib/src/shared/ or the design system
> layer?

No, leave it as is.
