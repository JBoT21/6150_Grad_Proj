import 'package:flutter/material.dart';
import '../widgets/progress_chart_stub.dart';
import '../widgets/stat_tile.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SizedBox(height: 16),

            // Top stats row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  StatTile(
                    label: "Class Avg",
                    value: "84",
                    icon: Icons.school,
                  ),
                  SizedBox(width: 12),
                  StatTile(
                    label: "Attempts",
                    value: "47",
                    icon: Icons.graphic_eq,
                  ),
                  SizedBox(width: 12),
                  StatTile(
                    label: "Struggle",
                    value: "thin (/θ/)",
                    icon: Icons.warning_amber_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Class progress chart
            ProgressChartStub(
              streakDays: 0,
              averageScore: 84,
              recentScores: const [75, 80, 82, 90, 88],
              label: 'Class Average (This Week)',
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Students',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const _StudentRow(
              name: 'Alice',
              avgScore: 90,
              attempts: 12,
              retainAudio: true,
            ),
            const _StudentRow(
              name: 'Ben',
              avgScore: 72,
              attempts: 15,
              retainAudio: false,
            ),
            const _StudentRow(
              name: 'Chloe',
              avgScore: 88,
              attempts: 9,
              retainAudio: true,
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                icon: const Icon(Icons.download_rounded),
                label: const Text('Export CSV'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  // later: teacher export
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final String name;
  final int avgScore;
  final int attempts;
  final bool retainAudio;

  const _StudentRow({
    required this.name,
    required this.avgScore,
    required this.attempts,
    required this.retainAudio,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          name.substring(0, 1),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Avg $avgScore • $attempts attempts'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.volume_up_rounded,
            color: retainAudio ? Colors.blueAccent : Colors.grey,
          ),
          const SizedBox(width: 12),
          Switch(
            value: retainAudio,
            onChanged: (_) {
              // future: toggle retainAudio per student
            },
          ),
        ],
      ),
    );
  }
}
