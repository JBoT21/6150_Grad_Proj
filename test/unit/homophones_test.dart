// Covers Homophones.addHomophone: bidirectional map mutation used to grow
// the homophone list at runtime (isHomophone's exact-match paths are
// already covered by scoring_test.dart).
import 'package:flutter_test/flutter_test.dart';
import 'package:team_3_f25_project/data/homophones.dart';

void main() {
  group('addHomophone', () {
    test('newly added pair recognized in both directions', () {
      final h = Homophones();
      h.addHomophone('gronk', 'zykk');

      expect(h.isHomophone('gronk', 'zykk'), isTrue);
      expect(h.isHomophone('zykk', 'gronk'), isTrue);
    });

    test('adding to a word that already has homophones extends the list', () {
      final h = Homophones();
      final before = List<String>.from(h.homophones['bear'] ?? []);

      h.addHomophone('bear', 'pear');

      expect(h.homophones['bear'], containsAll([...before, 'pear']));
      expect(h.homophones['pear'], contains('bear'));
    });

    test('does not affect unrelated words', () {
      final h = Homophones();
      h.addHomophone('gronk', 'zykk');

      expect(h.isHomophone('flower', 'flour'), isTrue);
      expect(h.isHomophone('gronk', 'flour'), isFalse);
    });

    test('instances are independent', () {
      final h1 = Homophones();
      final h2 = Homophones();

      h1.addHomophone('gronk', 'zykk');

      expect(h1.isHomophone('gronk', 'zykk'), isTrue);
      expect(h2.isHomophone('gronk', 'zykk'), isFalse);
    });
  });
}
