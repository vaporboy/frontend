import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soliplex_frontend/src/design/theme/theme.dart';
import 'package:soliplex_frontend/src/modules/diagnostics/models/http_event_group.dart';
import 'package:soliplex_frontend/src/modules/diagnostics/ui/http_status_display.dart';

import '../../helpers/http_event_factories.dart';

void main() {
  group('HttpStatusDisplay golden', () {
    testWidgets('success status in light theme', (tester) async {
      final group = HttpEventGroup(
        requestId: 'req-1',
        request: createRequestEvent(),
        response: createResponseEvent(statusCode: 200),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: Scaffold(
            body: Center(child: HttpStatusDisplay(group: group)),
          ),
        ),
      );

      await expectLater(
        find.byType(HttpStatusDisplay),
        matchesGoldenFile('http_status_display_light_success.png'),
      );
    });

    testWidgets('success status in dark theme', (tester) async {
      final group = HttpEventGroup(
        requestId: 'req-1',
        request: createRequestEvent(),
        response: createResponseEvent(statusCode: 200),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexDarkTheme(),
          home: Scaffold(
            body: Center(child: HttpStatusDisplay(group: group)),
          ),
        ),
      );

      await expectLater(
        find.byType(HttpStatusDisplay),
        matchesGoldenFile('http_status_display_dark_success.png'),
      );
    });

    testWidgets('pending status in light theme', (tester) async {
      final group = HttpEventGroup(
        requestId: 'req-1',
        request: createRequestEvent(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: Scaffold(
            body: Center(child: HttpStatusDisplay(group: group)),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(HttpStatusDisplay),
        matchesGoldenFile('http_status_display_light_pending.png'),
      );
    });

    testWidgets('client error status in light theme', (tester) async {
      final group = HttpEventGroup(
        requestId: 'req-1',
        request: createRequestEvent(),
        response: createResponseEvent(statusCode: 404),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: Scaffold(
            body: Center(child: HttpStatusDisplay(group: group)),
          ),
        ),
      );

      await expectLater(
        find.byType(HttpStatusDisplay),
        matchesGoldenFile('http_status_display_light_client_error.png'),
      );
    });

    testWidgets('stream complete in light theme', (tester) async {
      final group = HttpEventGroup(
        requestId: 'req-1',
        streamStart: createStreamStartEvent(),
        streamEnd: createStreamEndEvent(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: Scaffold(
            body: Center(child: HttpStatusDisplay(group: group)),
          ),
        ),
      );

      await expectLater(
        find.byType(HttpStatusDisplay),
        matchesGoldenFile('http_status_display_light_stream_complete.png'),
      );
    });
  });
}
