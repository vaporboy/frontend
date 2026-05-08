import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soliplex_frontend/src/design/theme/theme.dart';
import 'package:soliplex_frontend/src/design/widgets/status_dot.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: soliplexLightTheme(),
    home: Scaffold(body: child),
  );

  testWidgets('renders all four states without error', (tester) async {
    for (final state in StatusDotState.values) {
      await tester.pumpWidget(wrap(StatusDot(state: state)));
      expect(find.byType(StatusDot), findsOneWidget);
    }
  });

  testWidgets('pending state paints via CustomPaint', (tester) async {
    await tester.pumpWidget(
      wrap(const StatusDot(state: StatusDotState.pending)),
    );
    expect(
      find.descendant(
        of: find.byType(StatusDot),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  testWidgets('non-pending states use a Container with circle decoration', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const StatusDot(state: StatusDotState.done)));
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(StatusDot),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.border, isA<Border>());
  });

  testWidgets('size parameter controls rendered size', (tester) async {
    await tester.pumpWidget(
      wrap(const StatusDot(state: StatusDotState.done, size: 20)),
    );
    final size = tester.getSize(find.byType(StatusDot));
    expect(size.width, 20);
    expect(size.height, 20);
  });
}
