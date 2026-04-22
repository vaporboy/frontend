 # Design System Decisions

  Answers to open questions from audit-2026-04-22.md, section 7.

  ## 1. Missing spacing tokens

  > Should SoliplexSpacing be extended with s5=20 and s8=32?

  [Yes]

  ## 2. Border radius mismatch

  > Should the token scale be realigned to match actual usage?

  [Yes]
  
  ## 3. SymbolicColors uses Material palette directly. 
  > Should these become fields on SoliplexColors for tenant overridability?
  
  [Yes]

  ## 4. Unused context.monospace extension
  > Should this be canonized and adopted, or removed?
  
  [canonized and adopted]

  ## 5. Single-tenant reality. Only assets/branding/soliplex/ exists. The pubspec.yaml, flutter_launcher_icons, and flutter_native_splash configs all hardcode Soliplex assets. 
  > What is the expected timeline for a second tenant, and should the design system accommodate runtime tenant switching or only build-time flavors?
  
  [Second and additional tenants will be immediate; the design system should accommodate build-time tenant branding]

  ## 6. Color manifest format. Colors are defined as Dart const values in colors.dart. 
  > If tenants need to provide their own palettes, should colors move to a JSON/YAML manifest loaded at runtime, or stay as compile-time constants in per-tenant Dart files?
  
  [stay as compile-time constants in per-tenant Dart files]

  ## 7. Dark theme completeness. darkSoliplexColors exists but soliplexDarkTheme() does not — only soliplexLightTheme() is defined. 
  > Is dark mode a near-term priority, or is the dark palette aspirational?
  
  [dark mode is a near-term priority]

  ## 8. No motion tokens. The spacing, color, and radii token files exist, but there are no duration or curve tokens for animations. 
  > Is consistent motion a design goal?
  
  [Yes]

  ## 9. Diagnostics module styling. The diagnostics module has the highest density of inline TextStyle and EdgeInsets constructions. Is this module considered part of the design system surface, or is it an internal developer tool exempt from token discipline?
  
  [its part of the design and not exept from token discipline]

  ## 10. SectionCard scope. The SectionCard widget in room_info_widgets.dart is the most reusable container pattern but is scoped to the room module. Should it be promoted to lib/src/shared/ or the design system layer?
  
  [no, leave it as is]