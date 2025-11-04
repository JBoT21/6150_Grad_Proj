// lib/viewmodels/progress_view_model.dart
import 'package:flutter/foundation.dart';
import '../models/attempt.dart';
import '../services/attempts_repository.dart';

class ProgressViewModel extends ChangeNotifier {
  final AttemptsRepository repo;
  ProgressViewModel(this.repo);

  bool _loading = true;
  List<Attempt> _attempts = [];

  bool get loading => _loading;
  List<Attempt> get attempts => _attempts;
  int get totalAttempts => _attempts.length;
  int get uniqueWords => _attempts.map((a) => a.wordText).toSet().length;
  double get averageScore =>
      _attempts.isEmpty ? 0 : _attempts.fold(0, (s, a) => s + a.score) / _attempts.length;

  List<int> get recentScores =>
      _attempts.take(5).map((a) => a.score).toList().reversed.toList();

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _attempts = await repo.loadAll();
    _loading = false;
    notifyListeners();
  }
}
