import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

enum KindTileTone { neutral, pdf, md, success, error }

class KindTile extends StatelessWidget {
  const KindTile({
    super.key,
    required this.label,
    this.tone = KindTileTone.neutral,
    this.size = 44,
  });

  final String label;
  final KindTileTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radii = SoliplexTheme.of(context).radii;
    final colors = _colorsFor(cs);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(radii.sm),
        border: colors.border == null
            ? null
            : Border.all(color: colors.border!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.foreground,
          fontSize: size <= 32 ? 13 : 10,
          fontWeight: FontWeight.w600,
          letterSpacing: size <= 32 ? 0 : 0.4,
          height: 1,
        ),
      ),
    );
  }

  _TileColors _colorsFor(ColorScheme cs) {
    return switch (tone) {
      KindTileTone.neutral => _TileColors(
        background: cs.surfaceContainer,
        foreground: cs.onSurface,
        border: cs.outlineVariant,
      ),
      KindTileTone.pdf => _TileColors(
        background: Color.alphaBlend(
          const Color(0xFFB91C1C).withAlpha(20),
          cs.surface,
        ),
        foreground: const Color(0xFFB91C1C),
      ),
      KindTileTone.md => _TileColors(
        background: Color.alphaBlend(
          const Color(0xFF1D4ED8).withAlpha(20),
          cs.surface,
        ),
        foreground: const Color(0xFF1D4ED8),
      ),
      KindTileTone.success => _TileColors(
        background: const Color(0xFF16A34A),
        foreground: Colors.white,
      ),
      KindTileTone.error => _TileColors(
        background: cs.error,
        foreground: cs.onError,
      ),
    };
  }
}

class _TileColors {
  const _TileColors({
    required this.background,
    required this.foreground,
    this.border,
  });

  final Color background;
  final Color foreground;
  final Color? border;
}
