import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:soliplex_agent/soliplex_agent.dart' hide State;

import '../../../design/tokens/radii.dart';
import '../../../design/tokens/spacing.dart';
import '../../../shared/file_type_icons.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    required this.onSend,
    required this.onCancel,
    this.sessionState,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.selectedDocuments = const {},
    this.onFilterTap,
    this.onDocumentRemoved,
    this.onAttachFile,
  });

  final void Function(String text) onSend;
  final void Function() onCancel;
  final ReadonlySignal<AgentSessionState?>? sessionState;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final Set<RagDocument> selectedDocuments;
  final VoidCallback? onFilterTap;
  final void Function(RagDocument doc)? onDocumentRemoved;
  final VoidCallback? onAttachFile;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _chipsExpanded = true;

  @override
  void initState() {
    super.initState();
    _initController();
    _initFocusNode();
  }

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) _controller.dispose();
      _initController();
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _initFocusNode();
    }
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
  }

  void _initFocusNode() {
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty ||
        !widget.enabled ||
        _isActive(widget.sessionState?.peek())) {
      return;
    }
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  bool _isActive(AgentSessionState? state) =>
      state == AgentSessionState.spawning || state == AgentSessionState.running;

  @override
  Widget build(BuildContext context) {
    final state = widget.sessionState?.watch(context);
    final active = _isActive(state);
    final disabled = !widget.enabled || active;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(SoliplexSpacing.s2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.selectedDocuments.isNotEmpty)
            _AttachedDocsPanel(
              documents: widget.selectedDocuments,
              expanded: _chipsExpanded,
              onToggle: () =>
                  setState(() => _chipsExpanded = !_chipsExpanded),
              onRemove: disabled ? null : widget.onDocumentRemoved,
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.onFilterTap != null)
                IconButton(
                  icon: Icon(
                    Icons.filter_alt,
                    color: widget.selectedDocuments.isNotEmpty && !disabled
                        ? cs.primary
                        : null,
                  ),
                  tooltip: 'Filter documents',
                  onPressed: disabled ? null : widget.onFilterTap,
                ),
              if (widget.onAttachFile != null)
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  tooltip: 'Upload file to thread',
                  onPressed: disabled ? null : widget.onAttachFile,
                ),
              Expanded(
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.enter): _send,
                  },
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    readOnly: disabled,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SoliplexSpacing.s2),
              if (active)
                IconButton.filled(
                  icon: const Icon(Icons.stop),
                  tooltip: 'Cancel',
                  onPressed: widget.onCancel,
                  style: IconButton.styleFrom(
                    backgroundColor: cs.error,
                    foregroundColor: cs.onError,
                  ),
                )
              else
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => IconButton.filled(
                    icon: const Icon(Icons.send),
                    tooltip: 'Send',
                    onPressed: value.text.trim().isEmpty || disabled
                        ? null
                        : _send,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttachedDocsPanel extends StatelessWidget {
  const _AttachedDocsPanel({
    required this.documents,
    required this.expanded,
    required this.onToggle,
    required this.onRemove,
  });

  final Set<RagDocument> documents;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(RagDocument doc)? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final count = documents.length;
    return Container(
      margin: const EdgeInsets.only(bottom: SoliplexSpacing.s1),
      padding: const EdgeInsets.all(SoliplexSpacing.s2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(soliplexRadii.md),
      ),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(soliplexRadii.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: SoliplexSpacing.s1,
              ),
              child: Row(
                children: [
                  Text(
                    '$count document${count == 1 ? '' : 's'} selected',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    expanded ? Icons.expand_more : Icons.expand_less,
                    size: 16,
                    color: cs.primary,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: SoliplexSpacing.s2),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 160),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: SoliplexSpacing.s1,
                          runSpacing: SoliplexSpacing.s1,
                          children: [
                            for (final doc in documents)
                              Chip(
                                avatar: Icon(
                                  getFileTypeIcon(documentIconPath(doc)),
                                  size: 16,
                                ),
                                label: Text(documentDisplayName(doc)),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: onRemove == null
                                    ? null
                                    : () => onRemove!(doc),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
