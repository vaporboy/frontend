import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soliplex_frontend/src/design/theme/theme.dart';
import 'package:soliplex_frontend/src/design/widgets/kind_tile.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: soliplexLightTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders the label', (tester) async {
    await tester.pumpWidget(
      wrap(const KindTile(label: 'PDF', tone: KindTileTone.pdf)),
    );
    expect(find.text('PDF'), findsOneWidget);
  });

  testWidgets('default size is 44x44', (tester) async {
    await tester.pumpWidget(
      wrap(const KindTile(label: 'PDF', tone: KindTileTone.pdf)),
    );
    final size = tester.getSize(find.byType(KindTile));
    expect(size.width, 44);
    expect(size.height, 44);
  });

  testWidgets('size parameter overrides default', (tester) async {
    await tester.pumpWidget(
      wrap(const KindTile(label: 'A', tone: KindTileTone.success, size: 28)),
    );
    final size = tester.getSize(find.byType(KindTile));
    expect(size.width, 28);
    expect(size.height, 28);
  });

  testWidgets('all tones render without error', (tester) async {
    for (final tone in KindTileTone.values) {
      await tester.pumpWidget(wrap(KindTile(label: 'X', tone: tone)));
      expect(find.text('X'), findsOneWidget);
    }
  });

  testWidgets('success and error tones render with white text', (tester) async {
    await tester.pumpWidget(
      wrap(const KindTile(label: 'A', tone: KindTileTone.success)),
    );
    final text = tester.widget<Text>(
      find.descendant(of: find.byType(KindTile), matching: find.byType(Text)),
    );
    expect(text.style?.color, Colors.white);
  });
}
