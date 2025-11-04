// attempts_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attempt.dart';

class AttemptsRepository {
  static const _kKey = 'attempts_v1';

  Future<List<Attempt>> loadAll() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getStringList(_kKey) ?? <String>[];
      final list = raw.map(Attempt.fromJson).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      // Don’t propagate; VM will handle empty gracefully.
      return <Attempt>[];
    }
  }

  Future<void> saveAll(List<Attempt> items) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kKey, items.map((a) => a.toJson()).toList());
  }

  Future<void> add(Attempt a) async {
    final list = await loadAll();
    list.insert(0, a);
    await saveAll(list);
  }
}
