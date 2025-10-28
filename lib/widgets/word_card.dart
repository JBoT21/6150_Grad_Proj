import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {
  final String wordText;
  final String patternLabel;
  final String sampleSentence;
  final VoidCallback? onPractice;

  const WordCard({
    super.key,
    required this.wordText,
    required this.patternLabel,
    required this.sampleSentence,
    this.onPractice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: word info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main word
                  Text(
                    wordText,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Pattern / category label
                  Text(
                    patternLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Sample sentence
                  Text(
                    '"$sampleSentence"',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[800]),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right side: practice button
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onPressed: onPractice,
              child: const Text(
                'Practice',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
