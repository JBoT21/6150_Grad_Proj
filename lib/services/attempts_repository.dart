import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attempt.dart';

class AttemptsRepository {
  static const _kKey = 'attempts_v1';

  Future<List<Attempt>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kKey) ?? [];
    return raw.map((s) => Attempt.fromJson(s)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveAll(List<Attempt> attempts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kKey, attempts.map((a) => a.toJson()).toList());
  }

  Future<void> add(Attempt attempt) async {
    final list = await loadAll();
    list.insert(0, attempt);
    await saveAll(list);
  }
}
