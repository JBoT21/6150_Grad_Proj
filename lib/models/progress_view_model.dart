// progress_view_model.dart
import 'package:flutter/foundation.dart';
import '../models/attempt.dart';
import '../services/attempts_repository.dart';

class ProgressViewModel extends ChangeNotifier {
  final AttemptsRepository repo;
  ProgressViewModel(this.repo);

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  bool _hasLoadedOnce = false;

  List<Attempt> _attempts = [];
  List<Attempt> get attempts => _attempts;

  int get totalAttempts => _attempts.length;
  int get uniqueWords => _attempts.map((a) => a.wordText).toSet().length;
  double get averageScore =>
      _attempts.isEmpty ? 0 : _attempts.fold<int>(0, (s, a) => s + a.score) / _attempts.length;

  List<int> get recentScores =>
      _attempts.take(5).map((a) => a.score).toList().reversed.toList();

  Future<void> load({bool force = false}) async {
    if (_hasLoadedOnce && !force) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await repo.loadAll();
      _attempts = list..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _hasLoadedOnce = true;
    } catch (e) {
      _error = e.toString();
      _attempts = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);
}
