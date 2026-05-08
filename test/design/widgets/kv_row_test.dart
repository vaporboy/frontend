import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soliplex_frontend/src/design/theme/theme.dart';
import 'package:soliplex_frontend/src/design/widgets/kv_row.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(theme: soliplexLightTheme(), home: Scaffold(body: child));

  testWidgets('renders both key and value', (tester) async {
    await tester.pumpWidget(
      wrap(const KvRow(k: 'request_id', v: 'req_01HXA7P4B')),
    );

    final widget = tester.widget<Text>(find.byType(Text));
    expect(widget.textSpan?.toPlainText(), 'request_id req_01HXA7P4B');
  });

  testWidgets('key and value spans use different colors', (tester) async {
    await tester.pumpWidget(
      wrap(const KvRow(k: 'model', v: 'claude-sonnet-4.5')),
    );

    final widget = tester.widget<Text>(find.byType(Text));
    final spans = (widget.textSpan! as TextSpan).children!;
    expect(spans, hasLength(2));
    final keyColor = (spans.first as TextSpan).style?.color;
    final valueColor = (spans.last as TextSpan).style?.color;
    expect(keyColor, isNot(equals(valueColor)));
  });

  testWidgets('fontSize parameter is honored', (tester) async {
    await tester.pumpWidget(wrap(const KvRow(k: 'k', v: 'v', fontSize: 14)));

    final widget = tester.widget<Text>(find.byType(Text));
    expect(widget.style?.fontSize, 14);
  });

  testWidgets('text is discoverable via find.textContaining', (tester) async {
    await tester.pumpWidget(
      wrap(const KvRow(k: 'request_id', v: 'req_42')),
    );

    expect(find.textContaining('request_id'), findsOneWidget);
    expect(find.textContaining('req_42'), findsOneWidget);
  });
}
