import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:soliplex_agent/soliplex_agent.dart' hide State;

import '../../../../design/tokens/spacing.dart';
import '../../../../design/tokens/typography_x.dart';
import '../../../../design/widgets/kv_row.dart';
import '../../../../design/widgets/status_dot.dart';
import '../../../../design/widgets/status_pill.dart';
import '../../compute_display_messages.dart' show loadingMessageId;
import '../../execution_step.dart';
import '../../execution_tracker.dart';
import '../../message_expansions.dart';
import '../../room_providers.dart';
import '../copy_button.dart';
import 'timeline_entry.dart';

/// Vertical execution timeline rendered as a rail of dots connected by a
/// continuous line, matching the m-exec-step pattern in the design system
/// handoff. The outer collapse is preserved so long timelines stay compact
/// inside a chat answer until the user opens them.
class ExecutionTimeline extends ConsumerStatefulWidget {
  const ExecutionTimeline({
    super.key,
    required this.roomId,
    required this.messageId,
    required this.tracker,
  });

  final String roomId;
  final String messageId;
  final ExecutionTracker tracker;

  @override
  ConsumerState<ExecutionTimeline> createState() => _ExecutionTimelineState();
}

class _ExecutionTimelineState extends ConsumerState<ExecutionTimeline> {
  // See class doc on the previous implementation: expansion state for the
  // AwaitingText phase is kept local because loadingMessageId is reused
  // across runs and would leak open/closed state between responses.
  bool _loadingPhaseTimeline = false;
  final Set<String> _loadingPhaseSources = <String>{};

  MessageExpansion? _expansion;

  @override
  void initState() {
    super.initState();
    if (widget.messageId == loadingMessageId) return;
    _expansion = ref
        .read(messageExpansionsProvider)
        .forMessage(widget.roomId, widget.messageId);
  }

  bool get _expanded => _expansion?.timelineExpanded ?? _loadingPhaseTimeline;

  void _toggleExpanded() {
    setState(() {
      final next = !_expanded;
      if (_expansion != null) {
        _expansion!.timelineExpanded = next;
      } else {
        _loadingPhaseTimeline = next;
      }
    });
  }

  void _toggleSource(String activityId) {
    setState(() {
      final expansion = _expansion;
      if (expansion != null) {
        expansion.toggleSource(activityId);
        return;
      }
      if (!_loadingPhaseSources.remove(activityId)) {
        _loadingPhaseSources.add(activityId);
      }
    });
  }

  bool _isSourceExpanded(String activityId) =>
      _expansion?.isSourceExpanded(activityId) ??
      _loadingPhaseSources.contains(activityId);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = widget.tracker.timeline.watch(context);
    if (entries.isEmpty) return const SizedBox.shrink();

    final flat = _flatten(entries);

    return Padding(
      padding: const EdgeInsets.only(bottom: SoliplexSpacing.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _toggleExpanded,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${flat.length} event${flat.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: SoliplexSpacing.s2),
            for (var i = 0; i < flat.length; i++)
              _StepRow(rowData: flat[i], isLast: i == flat.length - 1),
          ],
        ],
      ),
    );
  }

  /// Flattens steps + their child activities into a single ordered list of
  /// rail rows. Matching the handoff demo, every step and every activity
  /// renders as an independent m-exec-step entry.
  List<_RowData> _flatten(List<TimelineEntry> entries) {
    final out = <_RowData>[];
    for (final entry in entries) {
      switch (entry) {
        case TimelineStep(:final step, :final activities):
          out.add(_RowData.fromStep(step));
          for (final activity in activities) {
            out.add(
              _RowData.fromActivity(
                activity,
                isExpanded: _isSourceExpanded(activity.messageId),
                onToggle: () => _toggleSource(activity.messageId),
              ),
            );
          }
        case TimelineOrphanActivity(:final activity):
          out.add(
            _RowData.fromActivity(
              activity,
              isExpanded: _isSourceExpanded(activity.messageId),
              onToggle: () => _toggleSource(activity.messageId),
            ),
          );
      }
    }
    return out;
  }
}

class _RowData {
  const _RowData({
    required this.label,
    required this.dotState,
    this.icon,
    this.meta,
    this.argDetails = const [],
    this.expandableSource,
    this.isSourceExpanded = false,
    this.onToggleSource,
  });

  factory _RowData.fromStep(ExecutionStep step) {
    return _RowData(
      label: step.label,
      dotState: switch (step.status) {
        StepStatus.active => StatusDotState.running,
        StepStatus.completed => StatusDotState.done,
        StepStatus.failed => StatusDotState.failed,
      },
      icon: _iconForStepType(step.type),
      meta: _formatDuration(step.timestamp),
    );
  }

  factory _RowData.fromActivity(
    SkillToolCallActivity activity, {
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final source = _pickSource(activity);
    final argDetails = _shortArgsAsKv(activity.args);
    return _RowData(
      label: activity.toolName,
      dotState: _statusToDotState(activity.status),
      icon: _iconForToolName(activity.toolName),
      meta: activity.status,
      argDetails: argDetails,
      expandableSource: argDetails.isEmpty ? source : null,
      isSourceExpanded: isExpanded,
      onToggleSource: source != null && argDetails.isEmpty ? onToggle : null,
    );
  }

  final String label;
  final StatusDotState dotState;
  final IconData? icon;
  final String? meta;
  final List<MapEntry<String, String>> argDetails;
  final String? expandableSource;
  final bool isSourceExpanded;
  final VoidCallback? onToggleSource;
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.rowData, required this.isLast});

  final _RowData rowData;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final mono = context.monospace;

    final hasExpandable = rowData.expandableSource != null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 2),
                StatusDot(state: rowData.dotState),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 2),
                      color: cs.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: SoliplexSpacing.s3),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: SoliplexSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: rowData.onToggleSource,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        if (rowData.icon != null) ...[
                          Icon(
                            rowData.icon,
                            size: 14,
                            color: rowData.dotState == StatusDotState.pending
                                ? cs.onSurfaceVariant
                                : cs.onSurface,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            rowData.label,
                            style: mono.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: rowData.dotState == StatusDotState.pending
                                  ? cs.onSurfaceVariant
                                  : cs.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: SoliplexSpacing.s2),
                        if (rowData.meta != null && rowData.meta!.isNotEmpty)
                          StatusPill(
                            label: rowData.meta!,
                            variant: StatusPillVariant.outline,
                            monospace: true,
                          ),
                        if (hasExpandable) ...[
                          const SizedBox(width: 4),
                          Icon(
                            rowData.isSourceExpanded
                                ? Icons.expand_more
                                : Icons.chevron_right,
                            size: 14,
                            color: cs.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (rowData.argDetails.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: SoliplexSpacing.s4,
                      runSpacing: 4,
                      children: [
                        for (final entry in rowData.argDetails)
                          KvRow(k: entry.key, v: entry.value),
                      ],
                    ),
                  ],
                  if (hasExpandable && rowData.isSourceExpanded)
                    _SourceBlock(source: rowData.expandableSource!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceBlock extends StatelessWidget {
  const _SourceBlock({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mono = context.monospace;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        padding: const EdgeInsets.all(SoliplexSpacing.s2),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CopyButton(text: source, iconSize: 14),
            ),
            SelectableText(
              source,
              style: mono.copyWith(fontSize: 12, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconForStepType(StepType type) => switch (type) {
  StepType.thinking => Icons.auto_awesome_outlined,
  StepType.toolCall => Icons.terminal,
};

IconData _iconForToolName(String toolName) {
  final lower = toolName.toLowerCase();
  if (lower.contains('search') || lower.contains('retriev')) {
    return Icons.search;
  }
  if (lower.contains('synth') ||
      lower.contains('compose') ||
      lower.contains('write')) {
    return Icons.auto_awesome_outlined;
  }
  if (lower.contains('cite') || lower.contains('check')) {
    return Icons.task_alt;
  }
  if (lower.contains('plan')) {
    return Icons.chevron_right;
  }
  return Icons.terminal;
}

StatusDotState _statusToDotState(String? status) {
  switch (status) {
    case 'in_progress':
    case 'running':
    case 'streaming':
      return StatusDotState.running;
    case 'failed':
    case 'error':
      return StatusDotState.failed;
    case 'done':
    case 'completed':
    case 'success':
      return StatusDotState.done;
    default:
      return StatusDotState.pending;
  }
}

/// Returns the activity's args as inline KV pairs when small enough to
/// render in a row of pills. Returns an empty list when the args are
/// empty, contain a long source-style payload (script/code/query), or
/// have any value over 80 chars.
List<MapEntry<String, String>> _shortArgsAsKv(Map<String, dynamic> args) {
  if (args.isEmpty) return const [];
  if (args.containsKey('script') ||
      args.containsKey('code') ||
      args.containsKey('query') && args.length == 1) {
    return const [];
  }
  if (args.length > 4) return const [];

  final out = <MapEntry<String, String>>[];
  for (final entry in args.entries) {
    final str = entry.value is String
        ? entry.value as String
        : entry.value.toString();
    if (str.length > 80) return const [];
    out.add(MapEntry(entry.key, str));
  }
  return out;
}

String? _pickSource(SkillToolCallActivity activity) {
  for (final key in const ['script', 'code', 'query']) {
    final value = activity.args[key];
    if (value is String && value.isNotEmpty) return value;
  }
  if (activity.args.isEmpty) return null;
  return const JsonEncoder.withIndent('  ').convert(activity.args);
}

String _formatDuration(Duration d) {
  final seconds = d.inMilliseconds / 1000;
  return '${seconds.toStringAsFixed(1)}s';
}
