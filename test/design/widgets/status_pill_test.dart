import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soliplex_frontend/src/design/theme/theme.dart';
import 'package:soliplex_frontend/src/design/widgets/status_pill.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: soliplexLightTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders the label', (tester) async {
    await tester.pumpWidget(wrap(const StatusPill(label: 'indexed')));
    expect(find.text('indexed'), findsOneWidget);
  });

  testWidgets('outline variant has a border', (tester) async {
    await tester.pumpWidget(
      wrap(
        const StatusPill(label: '0.92s', variant: StatusPillVariant.outline),
      ),
    );
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(StatusPill),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.border, isNotNull);
  });

  testWidgets('tonal variant uses a filled background', (tester) async {
    await tester.pumpWidget(
      wrap(const StatusPill(label: '200', tone: StatusPillTone.success)),
    );
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(StatusPill),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, isNotNull);
    expect(decoration.color, isNot(equals(const Color(0x00000000))));
  });

  testWidgets('letterSpacing parameter is forwarded to the text style', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const StatusPill(label: 'GET', letterSpacing: 0.5)),
    );
    final text = tester.widget<Text>(
      find.descendant(of: find.byType(StatusPill), matching: find.byType(Text)),
    );
    expect(text.style?.letterSpacing, 0.5);
  });

  testWidgets('all tones render without error', (tester) async {
    for (final tone in StatusPillTone.values) {
      await tester.pumpWidget(wrap(StatusPill(label: tone.name, tone: tone)));
      expect(find.text(tone.name), findsOneWidget);
    }
  });
}
