// Covers the plain data models' (de)serialization: Attempt's map/JSON
// round-trip (used when writing/reading practice attempts to/from
// sqflite and Firestore) and WordList.fromCSV (used when parsing the
// word list CSV in list_service.dart).
import 'package:flutter_test/flutter_test.dart';
import 'package:team_3_f25_project/models/attempt.dart';
import 'package:team_3_f25_project/models/wordlist.dart';

void main() {
  group('Attempt', () {
    final attempt = Attempt(
      uid: 1,
      wordText: 'the',
      listId: 2,
      score: 1,
      feedback: 'correct',
      createdAt: DateTime.utc(2026, 1, 15, 10, 30),
      duration: const Duration(milliseconds: 1500),
      recordingPath: '/tmp/the.m4a',
    );

    test('toMap/fromMap round-trips all fields', () {
      final restored = Attempt.fromMap(attempt.toMap());

      expect(restored.uid, attempt.uid);
      expect(restored.wordText, attempt.wordText);
      expect(restored.listId, attempt.listId);
      expect(restored.score, attempt.score);
      expect(restored.feedback, attempt.feedback);
      expect(restored.createdAt, attempt.createdAt);
      expect(restored.duration, attempt.duration);
      expect(restored.recordingPath, attempt.recordingPath);
    });

    test('toJson/fromJson round-trips all fields', () {
      final restored = Attempt.fromJson(attempt.toJson());

      expect(restored.uid, attempt.uid);
      expect(restored.wordText, attempt.wordText);
      expect(restored.listId, attempt.listId);
      expect(restored.score, attempt.score);
      expect(restored.feedback, attempt.feedback);
      expect(restored.createdAt, attempt.createdAt);
      expect(restored.duration, attempt.duration);
      expect(restored.recordingPath, attempt.recordingPath);
    });

    test('toMap stores duration in whole milliseconds', () {
      final map = attempt.toMap();
      expect(map['durationMs'], 1500);
    });
  });

  group('WordList.fromCSV', () {
    test('parses a well-formed row', () {
      final row = [
        '1',
        '2',
        '3',
        'Pre-Primer',
        'the',
        'sentence one',
        'sentence two',
        'sentence three',
      ];

      final word = WordList.fromCSV(row);

      expect(word.id, 1);
      expect(word.listId, 2);
      expect(word.priority, 3);
      expect(word.category, 'Pre-Primer');
      expect(word.word, 'the');
      expect(word.sentence1, 'sentence one');
      expect(word.sentence2, 'sentence two');
      expect(word.sentence3, 'sentence three');
    });

    test('priority is mutable after construction', () {
      final word = WordList.fromCSV([
        '1',
        '2',
        '3',
        'Pre-Primer',
        'the',
        's1',
        's2',
        's3',
      ]);

      word.priority = 9;

      expect(word.priority, 9);
    });
  });
}
