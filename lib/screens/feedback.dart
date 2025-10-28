import 'package:flutter/material.dart';
import '../widgets/feedback_card.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SizedBox(height: 16),
            FeedbackCard(
              score: 92,
              summaryFeedback:
              'Great /ʃ/ sound on "ship"! Work on the ending /p/.',
              tips: const [
                'Close your lips at the end: "ship", not "shi".',
                'Try saying it a little slower.',
              ],
            ),
            const SizedBox(height: 16),

            // Buttons row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Try Again'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/practice');
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.insights_rounded),
                    label: const Text('See My Progress'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/progress');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
