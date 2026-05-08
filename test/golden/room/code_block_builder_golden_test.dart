import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soliplex_frontend/src/design/theme/theme.dart';
import 'package:soliplex_frontend/src/modules/room/ui/markdown/code_block_builder.dart';

void main() {
  group('CodeBlockBuilder golden', () {
    testWidgets('plaintext code block in light theme', (tester) async {
      final theme = soliplexLightTheme();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: MarkdownBody(
                data: '```\nprint("hello")\n```',
                builders: {
                  'pre': CodeBlockBuilder(
                    preferredStyle: theme.textTheme.bodyMedium!,
                  ),
                },
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MarkdownBody),
        matchesGoldenFile('code_block_light_plaintext.png'),
      );
    });

    testWidgets('dart code block in light theme', (tester) async {
      final theme = soliplexLightTheme();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: MarkdownBody(
                data: '```dart\nvoid main() {\n  print("hello");\n}\n```',
                builders: {
                  'pre': CodeBlockBuilder(
                    preferredStyle: theme.textTheme.bodyMedium!,
                  ),
                },
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MarkdownBody),
        matchesGoldenFile('code_block_light_dart.png'),
      );
    });

    testWidgets('plaintext code block in dark theme', (tester) async {
      final theme = soliplexDarkTheme();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: MarkdownBody(
                data: '```\nprint("hello")\n```',
                builders: {
                  'pre': CodeBlockBuilder(
                    preferredStyle: theme.textTheme.bodyMedium!,
                  ),
                },
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MarkdownBody),
        matchesGoldenFile('code_block_dark_plaintext.png'),
      );
    });
  });
}
