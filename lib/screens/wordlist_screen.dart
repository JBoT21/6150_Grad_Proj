import 'package:flutter/material.dart';
import '../widgets/bottom_nav_scaffold.dart';
import '../widgets/word_card.dart';

class WordListScreen extends StatelessWidget {
  const WordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavScaffold(
      currentIndex: 0,
      title: 'Your Word Lists',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 16),

          // Dolch list example
          WordCard(
            wordText: 'the',
            patternLabel: 'Dolch - Grade K',
            sampleSentence: 'The dog ran.',
            onPractice: () {
              Navigator.pushNamed(context, '/practice');
            },
          ),

          // Phonics list example
          WordCard(
            wordText: 'ship',
            patternLabel: 'digraph /ʃ/ (sh)',
            sampleSentence: 'The ship is big.',
            onPractice: () {
              Navigator.pushNamed(context, '/practice');
            },
          ),

          // Minimal pairs list example
          WordCard(
            wordText: 'thin vs sin',
            patternLabel: 'Minimal Pair: th /θ/ vs s /s/',
            sampleSentence: 'The soup is thin.',
            onPractice: () {
              Navigator.pushNamed(context, '/practice');
            },
          ),
        ],
      ),
    );
  }
}
