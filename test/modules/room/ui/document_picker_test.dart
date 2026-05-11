import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soliplex_client/soliplex_client.dart' hide State;

import 'package:soliplex_frontend/src/design/theme/theme.dart';
import 'package:soliplex_frontend/src/modules/room/ui/document_picker.dart';

final _docs = [
  const RagDocument(id: '1', title: 'Report.pdf', uri: '/files/Report.pdf'),
  const RagDocument(id: '2', title: 'Summary.docx', uri: '/files/Summary.docx'),
  const RagDocument(id: '3', title: 'Data.xlsx', uri: '/files/Data.xlsx'),
  const RagDocument(id: '4', title: 'Notes.md', uri: '/files/Notes.md'),
];

Widget _wrap(Widget child) => MaterialApp(
  theme: soliplexLightTheme(),
  home: Scaffold(body: child),
);

void main() {
  group('DocumentPicker', () {
    testWidgets('displays all documents', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DocumentPicker(
            documents: _docs,
            selected: const {},
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Report.pdf'), findsOneWidget);
      expect(find.text('Summary.docx'), findsOneWidget);
      expect(find.text('Data.xlsx'), findsOneWidget);
      expect(find.text('Notes.md'), findsOneWidget);
    });

    testWidgets('renders PDF and MD kind tiles for matching extensions', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          DocumentPicker(
            documents: _docs,
            selected: const {},
            onChanged: (_) {},
          ),
        ),
      );

      // Each kind appears twice: as a filter chip label, and as a row tile.
      expect(find.text('PDF'), findsNWidgets(2));
      expect(find.text('MD'), findsNWidgets(2));
    });

    testWidgets('calls onChanged when document tapped', (tester) async {
      Set<RagDocument>? result;
      await tester.pumpWidget(
        _wrap(
          DocumentPicker(
            documents: _docs,
            selected: const {},
            onChanged: (s) => result = s,
          ),
        ),
      );

      await tester.tap(find.text('Report.pdf'));
      expect(result, {_docs[0]});
    });

    testWidgets('deselects already-selected document', (tester) async {
      Set<RagDocument>? result;
      await tester.pumpWidget(
        _wrap(
          DocumentPicker(
            documents: _docs,
            selected: {_docs[0]},
            onChanged: (s) => result = s,
          ),
        ),
      );

      await tester.tap(find.text('Report.pdf'));
      expect(result, isEmpty);
    });

    testWidgets('search filters documents', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DocumentPicker(
            documents: _docs,
            selected: const {},
            onChanged: (_) {},
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'report');
      await tester.pump();

      expect(find.text('Report.pdf'), findsOneWidget);
      expect(find.text('Summary.docx'), findsNothing);
      expect(find.text('Data.xlsx'), findsNothing);
    });

    testWidgets('search matches URI', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DocumentPicker(
            documents: _docs,
            selected: const {},
            onChanged: (_) {},
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '/files/Data');
      await tester.pump();

      expect(find.text('Data.xlsx'), findsOneWidget);
      expect(find.text('Report.pdf'), findsNothing);
    });

    testWidgets('PDF filter chip narrows list to PDFs only', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DocumentPicker(
            documents: _docs,
            selected: const {},
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.widgetWithText(FilterChip, 'PDF'));
      await tester.pump();

      expect(find.text('Report.pdf'), findsOneWidget);
      expect(find.text('Summary.docx'), findsNothing);
      expect(find.text('Data.xlsx'), findsNothing);
      expect(find.text('Notes.md'), findsNothing);
    });

    testWidgets('MD filter chip narrows list to MD/TXT', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DocumentPicker(
            documents: _docs,
            selected: const {},
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.widgetWithText(FilterChip, 'MD'));
      await tester.pump();

      expect(find.text('Notes.md'), findsOneWidget);
      expect(find.text('Report.pdf'), findsNothing);
    });

    testWidgets('footer shows N of M selected', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DocumentPicker(
            documents: _docs,
            selected: {_docs[0], _docs[1]},
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('2 of 4 selected'), findsOneWidget);
    });
  });

  group('showDocumentPicker', () {
    testWidgets('shows loading then documents', (tester) async {
      final completer = Completer<List<RagDocument>>();

      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDocumentPicker(
                context: context,
                fetchDocuments: () => completer.future,
                selected: const {},
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      // Loading state: spinner visible, Attach disabled.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final attach = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(attach.onPressed, isNull);

      // Resolve the future.
      completer.complete(_docs);
      await tester.pumpAndSettle();

      // Documents visible, Attach enabled.
      expect(find.text('Report.pdf'), findsOneWidget);
      final attachAfter = tester.widget<FilledButton>(
        find.byType(FilledButton),
      );
      expect(attachAfter.onPressed, isNotNull);
    });

    testWidgets('Attach button label includes count', (tester) async {
      Set<RagDocument>? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDocumentPicker(
                  context: context,
                  fetchDocuments: () => Future.value(_docs),
                  selected: const {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Attach'), findsOneWidget);

      // Select two docs — label updates.
      await tester.tap(find.text('Report.pdf'));
      await tester.pump();
      await tester.tap(find.text('Data.xlsx'));
      await tester.pump();

      expect(find.text('Attach 2 docs'), findsOneWidget);

      await tester.tap(find.text('Attach 2 docs'));
      await tester.pumpAndSettle();

      expect(result, {_docs[0], _docs[2]});
    });

    testWidgets('shows error with retry', (tester) async {
      int fetchCount = 0;
      final errorCompleter = Completer<List<RagDocument>>();

      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDocumentPicker(
                context: context,
                fetchDocuments: () {
                  fetchCount++;
                  if (fetchCount == 1) return errorCompleter.future;
                  return Future.value(_docs);
                },
                selected: const {},
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      errorCompleter.completeError(Exception('network'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to load documents.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Report.pdf'), findsOneWidget);
      expect(fetchCount, 2);
    });

    testWidgets('shows empty state when no documents', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDocumentPicker(
                context: context,
                fetchDocuments: () => Future.value(const []),
                selected: const {},
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('No documents in this room.'), findsOneWidget);
    });

    testWidgets('cancel returns null', (tester) async {
      Set<RagDocument>? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDocumentPicker(
                  context: context,
                  fetchDocuments: () => Future.value(_docs),
                  selected: const {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}
