import 'package:flutter/material.dart';
import '../widgets/bottom_nav_scaffold.dart';
import '../widgets/word_card.dart';
import '../widgets/progress_chart_stub.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavScaffold(
      currentIndex: 0,
      title: 'ReadRight',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Hi there 👋 Let's practice!",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recommended words (sample WordCards)
          WordCard(
            wordText: 'ship',
            patternLabel: 'digraph /ʃ/ (sh)',
            sampleSentence: 'The ship is big.',
            onPractice: () {
              Navigator.pushNamed(context, '/practice');
            },
          ),
          WordCard(
            wordText: 'thin',
            patternLabel: 'minimal pair th vs s',
            sampleSentence: 'The soup is thin.',
            onPractice: () {
              Navigator.pushNamed(context, '/practice');
            },
          ),

          const SizedBox(height: 8),

          // Quick progress chart preview
          ProgressChartStub(
            streakDays: 3,
            averageScore: 87,
            recentScores: const [92, 81, 75, 88, 90],
            label: 'Last 5 attempts',
          ),
        ],
      ),
    );
  }
}
