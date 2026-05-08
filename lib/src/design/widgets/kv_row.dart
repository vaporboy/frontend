import 'package:flutter/material.dart';

import '../tokens/typography_x.dart';

class KvRow extends StatelessWidget {
  const KvRow({
    super.key,
    required this.k,
    required this.v,
    this.fontSize = 12,
  });

  final String k;
  final String v;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mono = context.monospace.copyWith(fontSize: fontSize, height: 1.4);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$k ',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          TextSpan(text: v, style: TextStyle(color: cs.onSurface)),
        ],
      ),
      style: mono,
    );
  }
}
