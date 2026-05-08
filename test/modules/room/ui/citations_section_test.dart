import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soliplex_agent/soliplex_agent.dart' hide State;

import 'package:soliplex_frontend/src/design/theme/theme.dart';
import 'package:soliplex_frontend/src/modules/room/ui/citations_section.dart';

SourceReference _ref({
  required int index,
  String? title,
  bool pdf = false,
  List<String> headings = const [],
  String content = 'Test content',
  List<int> pageNumbers = const [],
}) => SourceReference(
  documentId: 'doc-$index',
  documentUri: pdf ? 's3://bucket/doc-$index.pdf' : 'file://doc-$index.txt',
  content: content,
  chunkId: 'chunk-$index',
  documentTitle: title ?? 'Document $index',
  headings: headings,
  pageNumbers: pageNumbers,
  index: index,
);

Widget _wrap(Widget child) => MaterialApp(
  theme: soliplexLightTheme(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('header shows uppercased plural source count', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CitationsSection(sourceReferences: [_ref(index: 1), _ref(index: 2)]),
      ),
    );

    expect(find.text('SOURCES · 2 CITATIONS'), findsOneWidget);
  });

  testWidgets('header is singular for one source', (tester) async {
    await tester.pumpWidget(
      _wrap(CitationsSection(sourceReferences: [_ref(index: 1)])),
    );

    expect(find.text('SOURCES · 1 CITATION'), findsOneWidget);
  });

  testWidgets('source titles are visible without tapping', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CitationsSection(
          sourceReferences: [
            _ref(index: 1, title: 'Alpha'),
            _ref(index: 2, title: 'Beta'),
          ],
        ),
      ),
    );

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
  });

  testWidgets('badge number reflects SourceReference.index', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CitationsSection(sourceReferences: [_ref(index: 4, title: 'Fourth')]),
      ),
    );

    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('quote, page number, and heading appear inline', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CitationsSection(
          sourceReferences: [
            _ref(
              index: 1,
              title: 'Doc',
              headings: ['Chapter 1'],
              content: 'Preview text here',
              pageNumbers: [5, 6],
            ),
          ],
        ),
      ),
    );

    expect(find.text('Preview text here'), findsOneWidget);
    expect(find.textContaining('p.5-6'), findsOneWidget);
    expect(find.textContaining('§Chapter 1'), findsOneWidget);
  });

  testWidgets('open-source button on PDF triggers onShowChunkVisualization', (
    tester,
  ) async {
    SourceReference? tapped;

    await tester.pumpWidget(
      _wrap(
        CitationsSection(
          sourceReferences: [_ref(index: 2, title: 'PDF File', pdf: true)],
          onShowChunkVisualization: (ref) => tapped = ref,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Open source'));
    await tester.pump();

    expect(tapped?.documentId, 'doc-2');
  });

  testWidgets('non-PDF source does not call onShowChunkVisualization', (
    tester,
  ) async {
    var called = false;

    await tester.pumpWidget(
      _wrap(
        CitationsSection(
          sourceReferences: [_ref(index: 1, title: 'Text File')],
          onShowChunkVisualization: (_) => called = true,
        ),
      ),
    );

    // The icon is still present, but tapping a non-PDF goes through launchUrl
    // (which is a no-op in test env) — never the PDF chunk callback.
    await tester.tap(find.byTooltip('Open source'));
    await tester.pump();

    expect(called, isFalse);
  });

  testWidgets('empty sources renders nothing', (tester) async {
    await tester.pumpWidget(
      _wrap(const CitationsSection(sourceReferences: [])),
    );

    expect(find.byType(SizedBox), findsOneWidget);
    expect(find.textContaining('SOURCE'), findsNothing);
  });

  testWidgets('strips simple markdown from quote content', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CitationsSection(
          sourceReferences: [
            _ref(
              index: 1,
              content: 'Use **80–90 mg/kg/day** of *amoxicillin*.',
            ),
          ],
        ),
      ),
    );

    expect(find.text('Use 80–90 mg/kg/day of amoxicillin.'), findsOneWidget);
    expect(find.textContaining('**'), findsNothing);
  });
}
