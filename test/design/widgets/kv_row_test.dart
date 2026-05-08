import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soliplex_frontend/src/design/theme/theme.dart';
import 'package:soliplex_frontend/src/design/widgets/kv_row.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: soliplexLightTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders both key and value', (tester) async {
    await tester.pumpWidget(
      wrap(const KvRow(k: 'request_id', v: 'req_01HXA7P4B')),
    );
    final richText = tester.widget<RichText>(find.byType(RichText));
    final text = (richText.text as TextSpan).toPlainText();
    expect(text, 'request_id req_01HXA7P4B');
  });

  testWidgets('key and value are styled differently', (tester) async {
    await tester.pumpWidget(
      wrap(const KvRow(k: 'model', v: 'claude-sonnet-4.5')),
    );
    final richText = tester.widget<RichText>(find.byType(RichText));
    final spans = (richText.text as TextSpan).children!;
    expect(spans, hasLength(2));
    final keyColor = (spans.first as TextSpan).style?.color;
    final valueColor = (spans.last as TextSpan).style?.color;
    expect(keyColor, isNot(equals(valueColor)));
  });

  testWidgets('fontSize parameter is honored', (tester) async {
    await tester.pumpWidget(wrap(const KvRow(k: 'k', v: 'v', fontSize: 14)));
    final richText = tester.widget<RichText>(find.byType(RichText));
    expect((richText.text as TextSpan).style?.fontSize, 14);
  });
}
