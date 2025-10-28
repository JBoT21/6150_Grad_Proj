import 'package:flutter/material.dart';
import '../widgets/bottom_nav_scaffold.dart';
import '../widgets/progress_chart_stub.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavScaffold(
      currentIndex: 2,
      title: 'Your Progress',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 16),

          ProgressChartStub(
            streakDays: 3,
            averageScore: 87,
            recentScores: const [92, 81, 75, 88, 90],
            label: 'Last 5 attempts',
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Recent Attempts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Recent attempt list (static)
          const _AttemptTile(
            word: 'ship',
            score: 92,
            date: 'Oct 26',
          ),
          const _AttemptTile(
            word: 'thin',
            score: 75,
            date: 'Oct 25',
          ),
          const _AttemptTile(
            word: 'read',
            score: 81,
            date: 'Oct 24',
          ),
        ],
      ),
    );
  }
}

// Internal helper widget for this screen only.
// (doesn't need its own file unless y'all want it)
class _AttemptTile extends StatelessWidget {
  final String word;
  final int score;
  final String date;

  const _AttemptTile({
    required this.word,
    required this.score,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final Color scoreColor = score >= 80
        ? Colors.green
        : (score >= 60 ? Colors.orange : Colors.red);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scoreColor.withValues(alpha: 0.15),
        child: Text(
          score.toString(),
          style: TextStyle(
            color: scoreColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        word,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Scored $score on $date'),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
