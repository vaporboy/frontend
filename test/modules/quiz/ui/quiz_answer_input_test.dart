import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soliplex_client/soliplex_client.dart';

import 'package:soliplex_frontend/src/design/theme/theme.dart';
import 'package:soliplex_frontend/src/modules/quiz/quiz_session.dart';
import 'package:soliplex_frontend/src/modules/quiz/ui/quiz_answer_input.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: soliplexLightTheme(),
    home: Scaffold(body: child),
  );

  group('QuizMultipleChoiceInput', () {
    testWidgets('renders all options with A/B/C letter tiles', (tester) async {
      await tester.pumpWidget(
        wrap(
          QuizMultipleChoiceInput(
            options: const ['Apple', 'Banana', 'Cherry'],
            selectedOption: null,
            questionState: const AwaitingInput(),
            onSelected: (_) {},
          ),
        ),
      );
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('calls onSelected when option tapped', (tester) async {
      String? selected;
      await tester.pumpWidget(
        wrap(
          QuizMultipleChoiceInput(
            options: const ['Apple', 'Banana'],
            selectedOption: null,
            questionState: const AwaitingInput(),
            onSelected: (v) => selected = v,
          ),
        ),
      );
      await tester.tap(find.text('Apple'));
      expect(selected, 'Apple');
    });

    testWidgets('shows ✓ mark on correct selected option', (tester) async {
      await tester.pumpWidget(
        wrap(
          QuizMultipleChoiceInput(
            options: const ['Apple', 'Banana'],
            selectedOption: 'Apple',
            questionState: const Answered(
              MultipleChoiceInput('Apple'),
              CorrectAnswer(),
            ),
            onSelected: (_) {},
          ),
        ),
      );
      expect(find.text('✓'), findsOneWidget);
    });

    testWidgets('shows × mark on wrong selected option', (tester) async {
      await tester.pumpWidget(
        wrap(
          QuizMultipleChoiceInput(
            options: const ['Apple', 'Banana'],
            selectedOption: 'Apple',
            questionState: const Answered(
              MultipleChoiceInput('Apple'),
              IncorrectAnswer(expectedAnswer: 'Banana'),
            ),
            onSelected: (_) {},
          ),
        ),
      );
      expect(find.text('×'), findsOneWidget);
    });

    testWidgets('marks correct option AND wrong selected option', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          QuizMultipleChoiceInput(
            options: const ['Apple', 'Banana'],
            selectedOption: 'Apple',
            questionState: const Answered(
              MultipleChoiceInput('Apple'),
              IncorrectAnswer(expectedAnswer: 'Banana'),
            ),
            onSelected: (_) {},
          ),
        ),
      );
      expect(find.text('✓'), findsOneWidget);
      expect(find.text('×'), findsOneWidget);
    });

    testWidgets('disables options when submitting', (tester) async {
      String? selected;
      await tester.pumpWidget(
        wrap(
          QuizMultipleChoiceInput(
            options: const ['Apple', 'Banana'],
            selectedOption: 'Apple',
            questionState: const Submitting(MultipleChoiceInput('Apple')),
            onSelected: (v) => selected = v,
          ),
        ),
      );
      await tester.tap(find.text('Banana'));
      expect(selected, isNull);
    });

    testWidgets('disables options when answered', (tester) async {
      String? selected;
      await tester.pumpWidget(
        wrap(
          QuizMultipleChoiceInput(
            options: const ['Apple', 'Banana'],
            selectedOption: 'Apple',
            questionState: const Answered(
              MultipleChoiceInput('Apple'),
              CorrectAnswer(),
            ),
            onSelected: (v) => selected = v,
          ),
        ),
      );
      await tester.tap(find.text('Banana'));
      expect(selected, isNull);
    });
  });

  group('QuizTextInput', () {
    testWidgets('renders text field', (tester) async {
      await tester.pumpWidget(
        wrap(
          QuizTextInput(
            controller: TextEditingController(),
            questionState: const AwaitingInput(),
            onChanged: (_) {},
            onSubmitted: () {},
          ),
        ),
      );
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('calls onChanged when typing', (tester) async {
      String? changed;
      await tester.pumpWidget(
        wrap(
          QuizTextInput(
            controller: TextEditingController(),
            questionState: const AwaitingInput(),
            onChanged: (v) => changed = v,
            onSubmitted: () {},
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'hello');
      expect(changed, 'hello');
    });

    testWidgets('disables text field when submitting', (tester) async {
      await tester.pumpWidget(
        wrap(
          QuizTextInput(
            controller: TextEditingController(text: 'answer'),
            questionState: const Submitting(TextInput('answer')),
            onChanged: (_) {},
            onSubmitted: () {},
          ),
        ),
      );
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('disables text field when answered', (tester) async {
      await tester.pumpWidget(
        wrap(
          QuizTextInput(
            controller: TextEditingController(),
            questionState: const Answered(TextInput('x'), CorrectAnswer()),
            onChanged: (_) {},
            onSubmitted: () {},
          ),
        ),
      );
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });
  });
}
