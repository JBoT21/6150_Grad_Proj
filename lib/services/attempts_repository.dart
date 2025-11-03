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

  // helper for demo/testing
  Future<void> seedFakeIfEmpty() async {
    final list = await loadAll();
    if (list.isNotEmpty) return;
    final now = DateTime.now();
    final demo = <Attempt>[
      Attempt(uid: 'demo', wordText: 'ship', score: 92, feedback: 'Great /ʃ/!', createdAt: now.subtract(const Duration(days: 0)), duration: const Duration(seconds: 2)),
      Attempt(uid: 'demo', wordText: 'thin', score: 75, feedback: 'Watch /θ/', createdAt: now.subtract(const Duration(days: 1)), duration: const Duration(seconds: 3)),
      Attempt(uid: 'demo', wordText: 'read', score: 81, feedback: 'Long vowel', createdAt: now.subtract(const Duration(days: 2)), duration: const Duration(seconds: 2)),
      Attempt(uid: 'demo', wordText: 'chip', score: 88, feedback: 'Nice /tʃ/', createdAt: now.subtract(const Duration(days: 3)), duration: const Duration(seconds: 2)),
      Attempt(uid: 'demo', wordText: 'this', score: 90, feedback: 'Good /ð/', createdAt: now.subtract(const Duration(days: 4)), duration: const Duration(seconds: 2)),
    ];
    await saveAll(demo);
  }
}
