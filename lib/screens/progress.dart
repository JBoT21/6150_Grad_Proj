// lib/screens/progress.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/progress_view_model.dart';
import '../widgets/progress_chart_stub.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressViewModel>(
      builder: (context, vm, _) {
        if (vm.loading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Your Progress')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final scores = vm.recentScores.isEmpty ? [0, 0, 0, 0, 0] : vm.recentScores;

        return Scaffold(
          appBar: AppBar(title: const Text('Your Progress')),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _Metric(label: 'Attempts', value: vm.totalAttempts.toString()),
                    const SizedBox(width: 8),
                    _Metric(label: 'Unique Words', value: vm.uniqueWords.toString()),
                    const SizedBox(width: 8),
                    _Metric(label: 'Avg Score', value: vm.averageScore.toStringAsFixed(0)),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              ProgressChartStub(
                streakDays: 0,
                averageScore: vm.averageScore,
                recentScores: scores,
                label: 'Last ${scores.length} attempts',
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recent Attempts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),

              ...vm.attempts.take(10).map((a) => ListTile(
                leading: CircleAvatar(child: Text(a.score.toString())),
                title: Text(a.wordText, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Scored ${a.score} on ${a.createdAt.toLocal().toString().split(" ").first}'),
                trailing: const Icon(Icons.chevron_right_rounded),
              )),
            ],
          ),
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}
