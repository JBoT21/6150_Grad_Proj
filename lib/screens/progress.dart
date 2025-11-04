// progress.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/progress_view_model.dart';
import '../widgets/progress_chart_stub.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    // Fire load after first frame to avoid context issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProgressViewModel>();
      vm.load(); // safe: idempotent
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressViewModel>(
      builder: (context, vm, _) {
        if (vm.loading) {
          return Scaffold(
            appBar: AppBar(title: Text('Your Progress')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (vm.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Your Progress')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Could not load progress.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(vm.error!, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => vm.refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (vm.attempts.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Your Progress')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.insights_outlined, size: 40),
                  const SizedBox(height: 8),
                  const Text('No attempts yet'),
                  const SizedBox(height: 4),
                  Text(
                    'Practice a word to see your stats here.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        Navigator.popAndPushNamed(context, '/practice'),
                    child: const Text('Start practicing'),
                  ),
                ],
              ),
            ),
          );
        }

        final avg = vm.averageScore;
        final scores = vm.recentScores;

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
                    _Metric(
                      label: 'Attempts',
                      value: vm.totalAttempts.toString(),
                    ),
                    const SizedBox(width: 8),
                    _Metric(
                      label: 'Unique Words',
                      value: vm.uniqueWords.toString(),
                    ),
                    const SizedBox(width: 8),
                    _Metric(label: 'Avg Score', value: avg.toStringAsFixed(0)),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              ProgressChartStub(
                streakDays: 0,
                averageScore: avg,
                recentScores: scores.isEmpty ? const [0, 0, 0, 0, 0] : scores,
                label: 'Last ${scores.isEmpty ? 5 : scores.length} attempts',
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recent Attempts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              ...vm.attempts
                  .take(10)
                  .map(
                    (a) => ListTile(
                      leading: CircleAvatar(child: Text(a.score.toString())),
                      title: Text(
                        a.wordText,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Scored ${a.score} on ${a.createdAt.toLocal().toString().split(" ").first}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
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
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
