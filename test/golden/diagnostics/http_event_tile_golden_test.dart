import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soliplex_frontend/src/design/theme/theme.dart';
import 'package:soliplex_frontend/src/modules/diagnostics/models/http_event_group.dart';
import 'package:soliplex_frontend/src/modules/diagnostics/ui/http_event_tile.dart';

import '../../helpers/http_event_factories.dart';

void main() {
  group('HttpEventTile golden', () {
    testWidgets('default with success response in light theme', (tester) async {
      final group = HttpEventGroup(
        requestId: 'req-1',
        request: createRequestEvent(),
        response: createResponseEvent(statusCode: 200),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: HttpEventTile(group: group),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(HttpEventTile),
        matchesGoldenFile('http_event_tile_light_default.png'),
      );
    });

    testWidgets('dense mode in light theme', (tester) async {
      final group = HttpEventGroup(
        requestId: 'req-1',
        request: createRequestEvent(),
        response: createResponseEvent(statusCode: 200),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: HttpEventTile(group: group, dense: true),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(HttpEventTile),
        matchesGoldenFile('http_event_tile_light_dense.png'),
      );
    });

    testWidgets('selected state in light theme', (tester) async {
      final group = HttpEventGroup(
        requestId: 'req-1',
        request: createRequestEvent(),
        response: createResponseEvent(statusCode: 200),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexLightTheme(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: HttpEventTile(group: group, isSelected: true),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(HttpEventTile),
        matchesGoldenFile('http_event_tile_light_selected.png'),
      );
    });

    testWidgets('default in dark theme', (tester) async {
      final group = HttpEventGroup(
        requestId: 'req-1',
        request: createRequestEvent(),
        response: createResponseEvent(statusCode: 200),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: soliplexDarkTheme(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: HttpEventTile(group: group),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(HttpEventTile),
        matchesGoldenFile('http_event_tile_dark_default.png'),
      );
    });
  });
}
