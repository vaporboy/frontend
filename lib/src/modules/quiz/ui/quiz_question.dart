import 'package:flutter/material.dart';
import 'package:soliplex_client/soliplex_client.dart';

import '../../../design/theme/theme_extensions.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography_x.dart';
import '../quiz_session.dart';
import 'quiz_answer_input.dart';
import 'quiz_feedback.dart';

class QuizQuestionView extends StatelessWidget {
  const QuizQuestionView({
    super.key,
    required this.session,
    required this.answerController,
    required this.submissionError,
    required this.onSelectOption,
    required this.onTextChanged,
    required this.onSubmit,
    required this.onNext,
    required this.onRetry,
  });

  final QuizInProgress session;
  final TextEditingController answerController;
  final String? submissionError;
  final void Function(String option) onSelectOption;
  final void Function(String text) onTextChanged;
  final VoidCallback onSubmit;
  final VoidCallback onNext;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final question = session.currentQuestion;
    final questionState = session.questionState;
    final theme = Theme.of(context);

    final selectedOption = switch (questionState) {
      Composing(input: MultipleChoiceInput(:final selectedOption)) =>
        selectedOption,
      Submitting(input: MultipleChoiceInput(:final selectedOption)) =>
        selectedOption,
      Answered(input: MultipleChoiceInput(:final selectedOption)) =>
        selectedOption,
      _ => null,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SoliplexSpacing.s4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QuizHeader(session: session),
              const SizedBox(height: SoliplexSpacing.s4),
              Text(question.text, style: theme.textTheme.titleMedium),
              const SizedBox(height: SoliplexSpacing.s4),
              _buildInput(question, questionState, selectedOption),
              if (submissionError != null) ...[
                const SizedBox(height: SoliplexSpacing.s4),
                QuizErrorFeedback(message: submissionError!, onRetry: onRetry),
              ],
              if (questionState case Answered(:final result)) ...[
                const SizedBox(height: SoliplexSpacing.s4),
                QuizAnswerFeedback(result: result),
              ],
              const SizedBox(height: SoliplexSpacing.s4),
              _buildActionButton(questionState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    QuizQuestion question,
    QuestionState questionState,
    String? selectedOption,
  ) {
    return switch (question.type) {
      MultipleChoice(:final options) => QuizMultipleChoiceInput(
        options: options,
        selectedOption: selectedOption,
        questionState: questionState,
        onSelected: onSelectOption,
      ),
      FillBlank() || FreeForm() => QuizTextInput(
        controller: answerController,
        questionState: questionState,
        onChanged: onTextChanged,
        onSubmitted: onSubmit,
      ),
    };
  }

  Widget _buildActionButton(QuestionState questionState) {
    return switch (questionState) {
      AwaitingInput() => const FilledButton(
        onPressed: null,
        child: Text('Submit Answer'),
      ),
      Composing(:final canSubmit) => FilledButton(
        onPressed: canSubmit ? onSubmit : null,
        child: const Text('Submit Answer'),
      ),
      Submitting() => const FilledButton(
        onPressed: null,
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      Answered() => FilledButton(
        onPressed: onNext,
        child: Text(session.isLastQuestion ? 'See Results' : 'Next Question'),
      ),
    };
  }
}

class _QuizHeader extends StatelessWidget {
  const _QuizHeader({required this.session});

  final QuizInProgress session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radii = SoliplexTheme.of(context).radii;
    final mono = context.monospace;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SoliplexSpacing.s2,
            vertical: SoliplexSpacing.s1,
          ),
          decoration: BoxDecoration(
            color: Color.alphaBlend(cs.onSurface.withAlpha(15), cs.surface),
            borderRadius: BorderRadius.circular(radii.lg),
          ),
          child: Text(
            'Quiz · ${session.quiz.title}',
            style: theme.textTheme.labelMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: SoliplexSpacing.s3),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: session.progress,
              minHeight: 8,
              backgroundColor: cs.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
        ),
        const SizedBox(width: SoliplexSpacing.s3),
        Text(
          '${session.currentIndex + 1} / ${session.quiz.questionCount}',
          style: mono.copyWith(fontSize: 12, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
