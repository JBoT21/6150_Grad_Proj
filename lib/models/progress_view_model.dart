import 'package:flutter/foundation.dart';
import '../models/attempt.dart';
import '../services/attempts_repository.dart';

class ProgressViewModel extends ChangeNotifier {
  final AttemptsRepository repo;
  ProgressViewModel(this.repo);

  bool _loading = true;
  bool get loading => _loading;

  List<Attempt> _attempts = [];
  List<Attempt> get attempts => _attempts;

  int get totalAttempts => _attempts.length;

  int get uniqueWordsCount => _attempts.map((a) => a.word).toSet().length;

  double get averageScore {
    if (_attempts.isEmpty) return 0;
    final sum = _attempts.fold<int>(0, (acc, a) => acc + a.score);
    return sum / _attempts.length;
  }

  List<int> get lastFiveScores =>
      _attempts.take(5).map((a) => a.score).toList().reversed.toList();

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    _attempts = await repo.loadAll();

    _loading = false;
    notifyListeners();
  }
}
