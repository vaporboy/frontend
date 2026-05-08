import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:soliplex_agent/soliplex_agent.dart';

import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography_x.dart';

class GenUiTile extends StatelessWidget {
  const GenUiTile({super.key, required this.message});
  final GenUiMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(SoliplexSpacing.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.widgetName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: SoliplexSpacing.s2),
            SelectableText(
              const JsonEncoder.withIndent('  ').convert(message.data),
              style: context.monospace.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
