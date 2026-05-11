import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:soliplex_client/soliplex_client.dart' hide State;

import '../../../design/theme/theme_extensions.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography_x.dart';
import '../../../design/widgets/kind_tile.dart';
import '../../../shared/file_type_icons.dart';

enum _DocFilter { all, pdf, md, other }

class DocumentPicker extends StatefulWidget {
  const DocumentPicker({
    super.key,
    required this.documents,
    required this.selected,
    required this.onChanged,
    this.onSearchChanged,
  });

  final List<RagDocument> documents;
  final Set<RagDocument> selected;
  final ValueChanged<Set<RagDocument>> onChanged;
  final ValueChanged<int>? onSearchChanged;

  @override
  State<DocumentPicker> createState() => _DocumentPickerState();
}

class _DocumentPickerState extends State<DocumentPicker> {
  final _searchController = TextEditingController();
  String _query = '';
  _DocFilter _filter = _DocFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RagDocument> get _filtered {
    final byQuery = filterDocuments(widget.documents, _query);
    return switch (_filter) {
      _DocFilter.all => byQuery,
      _DocFilter.pdf =>
        byQuery.where((d) => _kindOf(d) == _DocKind.pdf).toList(),
      _DocFilter.md => byQuery.where((d) => _kindOf(d) == _DocKind.md).toList(),
      _DocFilter.other =>
        byQuery.where((d) => _kindOf(d) == _DocKind.other).toList(),
    };
  }

  void _toggle(RagDocument doc) {
    final next = Set<RagDocument>.of(widget.selected);
    if (!next.remove(doc)) next.add(doc);
    widget.onChanged(next);
  }

  void _setFilter(_DocFilter next) {
    setState(() => _filter = next);
    widget.onSearchChanged?.call(_filtered.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final filtered = _filtered;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SearchAndFilters(
          controller: _searchController,
          query: _query,
          docCount: widget.documents.length,
          activeFilter: _filter,
          onQueryChanged: (v) {
            setState(() => _query = v);
            widget.onSearchChanged?.call(_filtered.length);
          },
          onFilterChanged: _setFilter,
          onClear: () {
            setState(() {
              _searchController.clear();
              _query = '';
            });
            widget.onSearchChanged?.call(_filtered.length);
          },
        ),
        Flexible(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(SoliplexSpacing.s4),
                    child: Text(
                      'No documents found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    return _DocumentRow(
                      doc: doc,
                      isSelected: widget.selected.contains(doc),
                      onTap: () => _toggle(doc),
                    );
                  },
                ),
        ),
        _Footer(
          selectedCount: widget.selected.length,
          totalCount: widget.documents.length,
        ),
      ],
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.query,
    required this.docCount,
    required this.activeFilter,
    required this.onQueryChanged,
    required this.onFilterChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final int docCount;
  final _DocFilter activeFilter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<_DocFilter> onFilterChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SoliplexSpacing.s4,
        SoliplexSpacing.s2,
        SoliplexSpacing.s4,
        SoliplexSpacing.s2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search $docCount documents…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear search',
                      onPressed: onClear,
                    )
                  : null,
              isDense: true,
            ),
            onChanged: onQueryChanged,
          ),
          const SizedBox(height: SoliplexSpacing.s2),
          Wrap(
            spacing: SoliplexSpacing.s1,
            children: [
              for (final f in _DocFilter.values)
                FilterChip(
                  label: Text(_filterLabel(f)),
                  selected: activeFilter == f,
                  onSelected: (_) => onFilterChanged(f),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _filterLabel(_DocFilter f) => switch (f) {
    _DocFilter.all => 'All',
    _DocFilter.pdf => 'PDF',
    _DocFilter.md => 'MD',
    _DocFilter.other => 'Other',
  };
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.doc,
    required this.isSelected,
    required this.onTap,
  });

  final RagDocument doc;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radii = SoliplexTheme.of(context).radii;
    final mono = context.monospace;
    final kind = _kindOf(doc);

    return Material(
      color: isSelected
          ? Color.alphaBlend(cs.primary.withAlpha(15), cs.surface)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SoliplexSpacing.s4,
            vertical: SoliplexSpacing.s2,
          ),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => onTap(),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radii.xs),
                ),
              ),
              const SizedBox(width: SoliplexSpacing.s2),
              KindTile(label: kind.label, tone: kind.tone, size: 36),
              const SizedBox(width: SoliplexSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      documentDisplayName(doc),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (doc.uri.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          doc.uri,
                          style: mono.copyWith(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.selectedCount, required this.totalCount});

  final int selectedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SoliplexSpacing.s4,
        vertical: SoliplexSpacing.s3,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Text(
            '$selectedCount of $totalCount selected',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

enum _DocKind { pdf, md, other }

_DocKind _kindOf(RagDocument doc) {
  final ext = _extOf(doc);
  return switch (ext) {
    'pdf' => _DocKind.pdf,
    'md' || 'txt' => _DocKind.md,
    _ => _DocKind.other,
  };
}

extension on _DocKind {
  String get label => switch (this) {
    _DocKind.pdf => 'PDF',
    _DocKind.md => 'MD',
    _DocKind.other => '•',
  };

  KindTileTone get tone => switch (this) {
    _DocKind.pdf => KindTileTone.pdf,
    _DocKind.md => KindTileTone.md,
    _DocKind.other => KindTileTone.neutral,
  };
}

String _extOf(RagDocument doc) {
  final source = doc.uri.isNotEmpty ? doc.uri : doc.title;
  final clean = source.split('?').first.split('#').first;
  final dot = clean.lastIndexOf('.');
  if (dot == -1 || dot == clean.length - 1) return '';
  return clean.substring(dot + 1).toLowerCase();
}

/// Shows a document picker dialog and returns the updated selection.
///
/// Accepts a [fetchDocuments] factory so the dialog can show a loading state
/// and retry on failure.
///
/// Returns `null` if the dialog is dismissed without confirming.
Future<Set<RagDocument>?> showDocumentPicker({
  required BuildContext context,
  required Future<List<RagDocument>> Function() fetchDocuments,
  required Set<RagDocument> selected,
}) {
  var current = Set<RagDocument>.of(selected);
  var documentsFuture = fetchDocuments();
  return showDialog<Set<RagDocument>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => FutureBuilder<List<RagDocument>>(
        future: documentsFuture,
        builder: (context, snapshot) {
          final docs = snapshot.data;

          final Widget content;
          final bool canConfirm;
          if (snapshot.connectionState == ConnectionState.waiting) {
            canConfirm = false;
            content = const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            canConfirm = false;
            developer.log(
              'Failed to load documents',
              error: snapshot.error,
              stackTrace: snapshot.stackTrace,
            );
            content = Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load documents.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: SoliplexSpacing.s2),
                  TextButton.icon(
                    onPressed: () => setDialogState(() {
                      documentsFuture = fetchDocuments();
                    }),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (docs == null || docs.isEmpty) {
            canConfirm = true;
            content = Center(
              child: Padding(
                padding: const EdgeInsets.all(SoliplexSpacing.s4),
                child: Text(
                  'No documents in this room.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          } else {
            canConfirm = true;
            content = DocumentPicker(
              documents: docs,
              selected: current,
              onChanged: (s) => setDialogState(() => current = s),
            );
          }

          final theme = Theme.of(context);
          return AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(
              SoliplexSpacing.s5,
              SoliplexSpacing.s4,
              SoliplexSpacing.s4,
              SoliplexSpacing.s2,
            ),
            contentPadding: EdgeInsets.zero,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Attach documents', style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'Responses will only draw from documents you select.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 480),
              child: SizedBox(width: double.maxFinite, child: content),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: canConfirm
                    ? () => Navigator.pop(context, current)
                    : null,
                child: Text(_attachLabel(current.length)),
              ),
            ],
          );
        },
      ),
    ),
  );
}

String _attachLabel(int count) =>
    count == 0 ? 'Attach' : 'Attach $count doc${count == 1 ? '' : 's'}';
