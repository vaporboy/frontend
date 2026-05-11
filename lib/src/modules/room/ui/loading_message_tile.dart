import 'package:flutter/material.dart';
import 'package:soliplex_agent/soliplex_agent.dart' hide State;

import '../../../design/tokens/spacing.dart';
import '../execution_tracker.dart';
import 'execution/activity_indicator.dart';
import 'execution/execution_timeline.dart';
import 'execution/thinking_block.dart';

class LoadingMessageTile extends StatelessWidget {
  const LoadingMessageTile({
    super.key,
    required this.roomId,
    required this.messageId,
    this.executionTracker,
    this.streamingActivity,
  });

  final String roomId;
  final String messageId;
  final ExecutionTracker? executionTracker;
  final ActivityType? streamingActivity;

  @override
  Widget build(BuildContext context) {
    if (executionTracker != null) {
      return Semantics(
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (streamingActivity != null)
              ActivityIndicator(activity: streamingActivity!),
            ExecutionTimeline(
              roomId: roomId,
              messageId: messageId,
              tracker: executionTracker!,
            ),
            ExecutionThinkingBlock(
              roomId: roomId,
              messageId: messageId,
              tracker: executionTracker!,
            ),
          ],
        ),
      );
    }
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: SoliplexSpacing.s2),
          Text(
            'Thinking...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
