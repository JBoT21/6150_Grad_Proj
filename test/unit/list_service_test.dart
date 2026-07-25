// Covers WordService's priority-ordering logic (getTopPriority,
// getNextListID, getHighestPriority) against the real seed_words.csv
// asset, using the same fake path_provider the widget tests use so
// WordService can read/write its CSV on the desktop test runner.
import 'package:flutter_test/flutter_test.dart';
import 'package:team_3_f25_project/services/list_service.dart';

import '../helpers/word_practice_test_harness.dart';

void main() {
  setUpAll(setUpWordPracticeTestEnvironment);

  group('WordService priority navigation (seed_words.csv)', () {
    test('getTopPriority returns the list with the lowest priority', () async {
      expect(await WordService.getTopPriority(), 1);
    });

    test('getHighestPriority returns the largest priority in use', () async {
      expect(await WordService.getHighestPriority(), 5);
    });

    test('getNextListID returns the next-highest-priority list', () async {
      expect(await WordService.getNextListID(1), 2);
      expect(await WordService.getNextListID(3), 4);
    });

    test('getNextListID returns null after the last list', () async {
      expect(await WordService.getNextListID(5), isNull);
    });

    test('getNextListID returns null for an unknown list id', () async {
      expect(await WordService.getNextListID(999), isNull);
    });

    test('getListIds contains every list from the seed data', () async {
      final ids = await WordService.getListIds();
      expect(ids.toSet(), {1, 2, 3, 4, 5});
    });

    test('getWords only returns words for the requested list', () async {
      final words = await WordService.getWords(1);
      expect(words, isNotEmpty);
      expect(words.every((w) => w.listId == 1), isTrue);
    });
  });
}
