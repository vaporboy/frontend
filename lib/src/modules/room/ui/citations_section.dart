import 'package:flutter/material.dart';
import 'package:soliplex_agent/soliplex_agent.dart' hide State;
import 'package:url_launcher/url_launcher.dart';

import '../../../design/theme/theme_extensions.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography_x.dart';

class CitationsSection extends StatelessWidget {
  const CitationsSection({
    super.key,
    required this.sourceReferences,
    this.onShowChunkVisualization,
  });

  final List<SourceReference> sourceReferences;
  final void Function(SourceReference)? onShowChunkVisualization;

  @override
  Widget build(BuildContext context) {
    if (sourceReferences.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final count = sourceReferences.length;

    return Padding(
      padding: const EdgeInsets.only(top: SoliplexSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1, color: cs.outlineVariant),
          const SizedBox(height: SoliplexSpacing.s3),
          Text(
            'SOURCES · $count CITATION${count == 1 ? '' : 'S'}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: SoliplexSpacing.s2),
          for (var i = 0; i < sourceReferences.length; i++)
            _CitationCard(
              ref: sourceReferences[i],
              number: sourceReferences[i].index ?? i + 1,
              onShowChunkVisualization: onShowChunkVisualization,
            ),
        ],
      ),
    );
  }
}

class _CitationCard extends StatelessWidget {
  const _CitationCard({
    required this.ref,
    required this.number,
    this.onShowChunkVisualization,
  });

  final SourceReference ref;
  final int number;
  final void Function(SourceReference)? onShowChunkVisualization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radii = SoliplexTheme.of(context).radii;
    final mono = context.monospace;

    final filename =
        Uri.tryParse(ref.documentUri)?.pathSegments.lastOrNull ??
        ref.documentUri;
    final whereParts = <String>[
      if (filename.isNotEmpty) filename,
      if (ref.formattedPageNumbers != null) ref.formattedPageNumbers!,
      if (ref.headings.isNotEmpty) '§${ref.headings.first}',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: SoliplexSpacing.s2),
      padding: const EdgeInsets.all(SoliplexSpacing.s3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radii.md),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NumberBadge(number: number),
          const SizedBox(width: SoliplexSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.displayTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (whereParts.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    whereParts.join(' · '),
                    style: mono.copyWith(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (ref.content.isNotEmpty) ...[
                  const SizedBox(height: SoliplexSpacing.s2),
                  _QuoteBlock(
                    text: _stripMarkdown(ref.content),
                    accent: cs.primary,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: SoliplexSpacing.s1),
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 18),
            tooltip: 'Open source',
            onPressed: () => _openSource(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  void _openSource() {
    if (ref.isPdf && onShowChunkVisualization != null) {
      onShowChunkVisualization!(ref);
      return;
    }
    final uri = Uri.tryParse(ref.documentUri);
    if (uri != null && uri.hasScheme) launchUrl(uri);
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radii = SoliplexTheme.of(context).radii;
    final mono = context.monospace;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.primary.withAlpha(31),
        borderRadius: BorderRadius.circular(radii.sm),
      ),
      child: Text(
        '$number',
        style: mono.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: cs.primary,
          height: 1,
        ),
      ),
    );
  }
}

class _QuoteBlock extends StatelessWidget {
  const _QuoteBlock({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radii = SoliplexTheme.of(context).radii;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SoliplexSpacing.s3 - 2,
        vertical: SoliplexSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          left: BorderSide(color: accent.withAlpha(102), width: 2),
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(radii.sm),
          bottomRight: Radius.circular(radii.sm),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
          color: cs.onSurface,
          height: 1.45,
        ),
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Strips common markdown markers (bold, italic, inline code, headings, list
/// bullets, link text) so that the resulting plain text reads cleanly inside
/// the italic quote block. Citation chunks are typically short prose, not
/// rich markdown — a regex pass is enough.
String _stripMarkdown(String input) {
  var out = input.trim();
  out = out.replaceAll(RegExp(r'^\s*#+\s+', multiLine: true), '');
  out = out.replaceAll(RegExp(r'^\s*[-+]\s+', multiLine: true), '');
  out = out.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\([^)]+\)'),
    (m) => m.group(1)!,
  );
  out = out.replaceAllMapped(RegExp(r'\*+(.+?)\*+'), (m) => m.group(1)!);
  out = out.replaceAllMapped(RegExp(r'__(.+?)__'), (m) => m.group(1)!);
  out = out.replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m.group(1)!);
  return out;
}
