import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soliplex_frontend/src/design/theme/theme.dart';
import 'package:soliplex_frontend/src/shared/copy_button.dart';

void main() {
  group('CopyButton golden', () {
    testWidgets('default state in light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: const Scaffold(
            body: Center(child: CopyButton(text: 'hello')),
          ),
        ),
      );
      await expectLater(
        find.byType(CopyButton),
        matchesGoldenFile('copy_button_light_default.png'),
      );
    });

    testWidgets('default state in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexDarkTheme(),
          home: const Scaffold(
            body: Center(child: CopyButton(text: 'hello')),
          ),
        ),
      );
      await expectLater(
        find.byType(CopyButton),
        matchesGoldenFile('copy_button_dark_default.png'),
      );
    });

    testWidgets('custom tooltip text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: const Scaffold(
            body: Center(
              child: CopyButton(text: 'hello', tooltip: 'Copy code'),
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(CopyButton),
        matchesGoldenFile('copy_button_custom_tooltip.png'),
      );
    });
  });
}
