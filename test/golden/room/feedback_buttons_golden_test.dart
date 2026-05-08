import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soliplex_frontend/src/design/theme/theme.dart';
import 'package:soliplex_frontend/src/modules/room/ui/feedback_buttons.dart';

void main() {
  group('FeedbackButtons golden', () {
    testWidgets('idle state in light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: Scaffold(
            body: Center(
              child: FeedbackButtons(onFeedbackSubmit: (_, __) {}),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(FeedbackButtons),
        matchesGoldenFile('feedback_buttons_light_idle.png'),
      );
    });

    testWidgets('idle state in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexDarkTheme(),
          home: Scaffold(
            body: Center(
              child: FeedbackButtons(onFeedbackSubmit: (_, __) {}),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(FeedbackButtons),
        matchesGoldenFile('feedback_buttons_dark_idle.png'),
      );
    });
  });
}
