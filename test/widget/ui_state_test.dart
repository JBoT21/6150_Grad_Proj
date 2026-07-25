// Covers the small presentational widgets WordPracticeScreen composes to
// show pronunciation progress: the word being practiced, and the mic
// button's recording/idle state.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_3_f25_project/widgets/record_button.dart';
import 'package:team_3_f25_project/widgets/word_card.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('WordCard', () {
    testWidgets('shows the current word to practice', (tester) async {
      await tester.pumpWidget(
        wrap(
          const WordCard(
            wordText: 'bear',
            patternLabel: 'Pattern label',
            sampleSentence: 'Sample sentence',
          ),
        ),
      );

      expect(find.text('bear'), findsOneWidget);
    });

    testWidgets('updates when moving to the next word', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        wrap(
          WordCard(
            key: key,
            wordText: 'bear',
            patternLabel: 'Pattern label',
            sampleSentence: 'Sample sentence',
          ),
        ),
      );
      expect(find.text('bear'), findsOneWidget);

      // simulates _nextWord swapping in a new currentWord after an attempt
      await tester.pumpWidget(
        wrap(
          WordCard(
            key: key,
            wordText: 'flour',
            patternLabel: 'Pattern label',
            sampleSentence: 'Sample sentence',
          ),
        ),
      );

      expect(find.text('bear'), findsNothing);
      expect(find.text('flour'), findsOneWidget);
    });
  });

  group('RecordButton (mic state during an attempt)', () {
    testWidgets('shows mic icon and idle label when not recording', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(RecordButton(isRecording: false, onTap: () {})),
      );

      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
      expect(find.text('Tap to record'), findsOneWidget);
    });

    testWidgets('shows stop icon and recording label while listening', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(RecordButton(isRecording: true, onTap: () {})),
      );

      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
      expect(find.text('Recording...'), findsOneWidget);
    });

    testWidgets('tapping while idle starts listening', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(RecordButton(isRecording: false, onTap: () => tapped = true)),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('is not tappable once speech recognition is unavailable', (
      tester,
    ) async {
      // WordPracticeScreen passes onTap: null when !_speechEnabled
      await tester.pumpWidget(
        wrap(const RecordButton(isRecording: false, onTap: null)),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNull);
    });
  });
}
