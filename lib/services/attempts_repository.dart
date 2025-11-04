// lib/services/attempts_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attempt.dart';

class AttemptsRepository {
  static const _kKey = 'attempts_v1';

  Future<List<Attempt>> loadAll() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_kKey) ?? <String>[];
    final list = raw.map(Attempt.fromJson).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
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
