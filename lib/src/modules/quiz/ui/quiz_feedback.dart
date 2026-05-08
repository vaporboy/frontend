import 'package:flutter/material.dart';
import 'package:soliplex_client/soliplex_client.dart';

import '../../../design/theme/theme_extensions.dart';
import '../../../design/tokens/spacing.dart';

class QuizAnswerFeedback extends StatelessWidget {
  const QuizAnswerFeedback({super.key, required this.result});

  final QuizAnswerResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radii = SoliplexTheme.of(context).radii;
    final isCorrect = result.isCorrect;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SoliplexSpacing.s4,
        vertical: SoliplexSpacing.s3 + 2,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radii.md),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCorrect ? 'CORRECT' : 'CORRECT ANSWER',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          if (result case IncorrectAnswer(:final expectedAnswer)) ...[
            Text(
              expectedAnswer,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ] else
            Text(
              'Nice work — answer accepted.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
        ],
      ),
    );
  }
}

class QuizErrorFeedback extends StatelessWidget {
  const QuizErrorFeedback({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radii = SoliplexTheme.of(context).radii;

    return Container(
      padding: const EdgeInsets.all(SoliplexSpacing.s4),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(radii.md),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error),
          const SizedBox(width: SoliplexSpacing.s2),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onErrorContainer,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
