// Drives the real WordPracticeScreen end to end: real widget, real
// correctness/DB/navigation logic, with every native plugin (mic,
// speech recognition, permissions, TTS, sqlite) faked so it can run
// under `flutter test`. A "spoken" word is simulated by injecting a
// speech_to_text recognition result directly -- see
// test/helpers/word_practice_test_harness.dart for why real audio itself
// can't be simulated here, only the recognizer's output.
//
// Everything runs inside tester.runAsync() because DatabaseHelper uses
// sqflite_common_ffi, which does real cross-isolate I/O that the widget
// test's fake-time zone won't otherwise let resolve; pumpUntilFound (see
// the harness) is used instead of pumpAndSettle wherever that I/O sits
// behind the widget tree, since pumpAndSettle doesn't wait for it either.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_3_f25_project/screens/word_practice_page.dart';
import 'package:team_3_f25_project/services/user_db.dart';
import 'package:team_3_f25_project/widgets/record_button.dart';

import '../helpers/word_practice_test_harness.dart';

const _testUid = 1;
const _testListId = 1; // seed_words.csv list 1, first word is "the"

void main() {
  setUpAll(setUpWordPracticeTestEnvironment);

  setUp(() async {
    await resetWordPracticeDatabase(uid: _testUid, listId: _testListId);
    mockSpeechToTextChannel();
  });

  Future<void> startListeningForCurrentWord(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: WordPracticeScreen()));
    await pumpUntilFound(tester, find.text('the'));
    expect(find.text('the'), findsOneWidget);

    await tester.tap(find.byType(RecordButton));
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  testWidgets('completion: correctly recognized word shows success feedback', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await startListeningForCurrentWord(tester);

      await simulateSpeechResult('the');
      await pumpUntilFound(tester, find.byIcon(Icons.check_rounded));

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);

      final correctWords = await DatabaseHelper.instance.getAllCorrectWords(
        _testUid,
      );
      expect(correctWords, contains('the'));
    });
    // Disposing WordPracticeScreen calls speechToText.stop() again, which
    // schedules its own internal 2s "final timeout" timer; force disposal
    // now and flush it, so it's not still pending when the test tears down.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('failure: incorrectly recognized word shows try-again feedback', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await startListeningForCurrentWord(tester);

      await simulateSpeechResult('banana');
      await pumpUntilFound(tester, find.byIcon(Icons.close));

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);

      final correctWords = await DatabaseHelper.instance.getAllCorrectWords(
        _testUid,
      );
      expect(correctWords, isNot(contains('the')));
    });
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('completion: a homophone of the word still counts as correct', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await startListeningForCurrentWord(tester);

      // "thee" is listed as a homophone of "the" in lib/data/homophones.dart
      await simulateSpeechResult('thee');
      await pumpUntilFound(tester, find.byIcon(Icons.check_rounded));

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });
}
