import 'package:flutter/material.dart';
import 'package:soliplex_client/soliplex_client.dart';

import '../../../design/theme/theme_extensions.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/widgets/kind_tile.dart';
import '../quiz_session.dart';

class QuizMultipleChoiceInput extends StatelessWidget {
  const QuizMultipleChoiceInput({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.questionState,
    required this.onSelected,
  });

  final List<String> options;
  final String? selectedOption;
  final QuestionState questionState;
  final void Function(String option) onSelected;

  @override
  Widget build(BuildContext context) {
    final isDisabled = questionState is Answered || questionState is Submitting;
    final answeredResult = switch (questionState) {
      Answered(:final result) => result,
      _ => null,
    };

    return Column(
      children: [
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: SoliplexSpacing.s2),
            child: _OptionTile(
              option: options[i],
              letter: _letterFor(i),
              isSelected: selectedOption == options[i],
              answered: answeredResult,
              onTap: isDisabled ? null : () => onSelected(options[i]),
            ),
          ),
      ],
    );
  }

  static String _letterFor(int index) =>
      index < 26 ? String.fromCharCode(65 + index) : '${index + 1}';
}

enum _ChoiceState { idle, picked, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.letter,
    required this.isSelected,
    required this.answered,
    required this.onTap,
  });

  final String option;
  final String letter;
  final bool isSelected;
  final QuizAnswerResult? answered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radii = SoliplexTheme.of(context).radii;

    final state = _resolveState();
    final colors = _colorsFor(state, cs);

    return Material(
      color: colors.background,
      borderRadius: BorderRadius.circular(radii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SoliplexSpacing.s4 - 2,
            vertical: SoliplexSpacing.s3,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(radii.md),
          ),
          child: Row(
            children: [
              KindTile(
                label: letter,
                tone: switch (state) {
                  _ChoiceState.correct => KindTileTone.success,
                  _ChoiceState.wrong => KindTileTone.error,
                  _ => KindTileTone.neutral,
                },
                size: 28,
              ),
              const SizedBox(width: SoliplexSpacing.s3),
              Expanded(child: Text(option, style: theme.textTheme.bodyMedium)),
              if (state == _ChoiceState.correct) ...[
                const SizedBox(width: SoliplexSpacing.s2),
                _Mark(symbol: '✓', tone: KindTileTone.success),
              ] else if (state == _ChoiceState.wrong) ...[
                const SizedBox(width: SoliplexSpacing.s2),
                _Mark(symbol: '×', tone: KindTileTone.error),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _ChoiceState _resolveState() {
    final r = answered;
    if (r == null) {
      return isSelected ? _ChoiceState.picked : _ChoiceState.idle;
    }
    final isCorrectOption = switch (r) {
      CorrectAnswer() => isSelected,
      IncorrectAnswer(:final expectedAnswer) =>
        expectedAnswer.trim().toLowerCase() == option.trim().toLowerCase(),
    };
    if (isCorrectOption) return _ChoiceState.correct;
    if (isSelected) return _ChoiceState.wrong;
    return _ChoiceState.idle;
  }

  _TileColors _colorsFor(_ChoiceState state, ColorScheme cs) {
    return switch (state) {
      _ChoiceState.idle => _TileColors(
        background: cs.surfaceContainerLow,
        border: cs.outlineVariant,
      ),
      _ChoiceState.picked => _TileColors(
        background: Color.alphaBlend(cs.primary.withAlpha(20), cs.surface),
        border: cs.primary.withAlpha(102),
      ),
      _ChoiceState.correct => _TileColors(
        background: Color.alphaBlend(
          const Color(0xFF16A34A).withAlpha(31),
          cs.surface,
        ),
        border: const Color(0xFF16A34A).withAlpha(115),
      ),
      _ChoiceState.wrong => _TileColors(
        background: cs.errorContainer,
        border: cs.error.withAlpha(153),
      ),
    };
  }
}

class _TileColors {
  const _TileColors({required this.background, required this.border});
  final Color background;
  final Color border;
}

class _Mark extends StatelessWidget {
  const _Mark({required this.symbol, required this.tone});

  final String symbol;
  final KindTileTone tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (Color bg, Color fg) = switch (tone) {
      KindTileTone.success => (const Color(0xFF16A34A), Colors.white),
      KindTileTone.error => (cs.error, cs.onError),
      _ => (cs.surfaceContainer, cs.onSurface),
    };
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        symbol,
        style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class QuizTextInput extends StatelessWidget {
  const QuizTextInput({
    super.key,
    required this.controller,
    required this.questionState,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final QuestionState questionState;
  final void Function(String text) onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final isDisabled = questionState is Answered || questionState is Submitting;

    return TextField(
      controller: controller,
      enabled: !isDisabled,
      textInputAction: TextInputAction.done,
      onSubmitted: isDisabled ? null : (_) => onSubmitted(),
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Type your answer...',
        border: OutlineInputBorder(),
      ),
    );
  }
}
