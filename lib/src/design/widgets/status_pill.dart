import 'package:flutter/material.dart';

import '../tokens/spacing.dart';

enum StatusPillTone { neutral, info, success, warning, error }

enum StatusPillVariant { tonal, outline }

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = StatusPillTone.neutral,
    this.variant = StatusPillVariant.tonal,
    this.monospace = false,
    this.letterSpacing,
  });

  final String label;
  final StatusPillTone tone;
  final StatusPillVariant variant;
  final bool monospace;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = _colorsFor(cs);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SoliplexSpacing.s2 - 2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(4),
        border: colors.border == null
            ? null
            : Border.all(color: colors.border!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: letterSpacing,
          fontFamily: monospace ? _monoFamily : null,
          fontFamilyFallback: monospace ? const ['monospace'] : null,
          height: 1.2,
        ),
      ),
    );
  }

  _PillColors _colorsFor(ColorScheme cs) {
    if (variant == StatusPillVariant.outline) {
      return _PillColors(
        background: Colors.transparent,
        foreground: cs.onSurfaceVariant,
        border: cs.outlineVariant,
      );
    }
    return switch (tone) {
      StatusPillTone.neutral => _PillColors(
        background: Color.alphaBlend(cs.onSurface.withAlpha(20), cs.surface),
        foreground: cs.onSurface,
      ),
      StatusPillTone.info => _PillColors(
        background: Color.alphaBlend(
          const Color(0xFF2563EB).withAlpha(38),
          cs.surface,
        ),
        foreground: const Color(0xFF1D4ED8),
      ),
      StatusPillTone.success => _PillColors(
        background: Color.alphaBlend(
          const Color(0xFF16A34A).withAlpha(38),
          cs.surface,
        ),
        foreground: const Color(0xFF15803D),
      ),
      StatusPillTone.warning => _PillColors(
        background: Color.alphaBlend(
          const Color(0xFFF97316).withAlpha(46),
          cs.surface,
        ),
        foreground: const Color(0xFFC2410C),
      ),
      StatusPillTone.error => _PillColors(
        background: cs.errorContainer,
        foreground: cs.onErrorContainer,
      ),
    };
  }
}

class _PillColors {
  const _PillColors({
    required this.background,
    required this.foreground,
    this.border,
  });

  final Color background;
  final Color foreground;
  final Color? border;
}

const String _monoFamily =
    // Use the platform-native monospace via family fallback; Flutter
    // resolves the first available. Cupertino picks SF Mono, others
    // fall through to 'monospace'. Kept inline to avoid pulling in a
    // BuildContext just to resolve the family.
    'SF Mono';
