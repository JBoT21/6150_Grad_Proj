// Covers the correct/incorrect pronunciation decision used by
// WordPracticeScreen._isCorrect: exact match, then homophone fallback.
import 'package:flutter_test/flutter_test.dart';
import 'package:team_3_f25_project/data/homophones.dart';

bool isCorrect(String recognizedWord, String currentWord) {
  if (recognizedWord.toLowerCase() == currentWord.toLowerCase()) {
    return true;
  }
  return Homophones().isHomophone(recognizedWord, currentWord);
}

void main() {
  group('completions (word recognized correctly)', () {
    test('exact match counts as correct', () {
      expect(isCorrect('the', 'the'), isTrue);
    });

    test('match is case-insensitive', () {
      expect(isCorrect('The', 'the'), isTrue);
      expect(isCorrect('BEAR', 'bear'), isTrue);
    });

    test('homophone counts as correct', () {
      expect(isCorrect('bare', 'bear'), isTrue);
      expect(isCorrect('flower', 'flour'), isTrue);
    });

    test('homophone match is order independent', () {
      expect(isCorrect('flour', 'flower'), isTrue);
    });
  });

  group('failures (word not recognized correctly)', () {
    test('unrelated word counts as incorrect', () {
      expect(isCorrect('cat', 'the'), isFalse);
    });

    test('empty recognized text counts as incorrect', () {
      expect(isCorrect('', 'the'), isFalse);
    });

    test('similar but non-homophone word counts as incorrect', () {
      expect(isCorrect('there', 'the'), isFalse);
    });
  });
}
