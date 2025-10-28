import 'package:flutter/material.dart';
import '../widgets/bottom_nav_scaffold.dart';
import '../widgets/record_button.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavScaffold(
      currentIndex: 1,
      title: 'Practice',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Target word
              Text(
                'ship',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The ship is big.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 32),

              // Record button
              RecordButton(
                isRecording: false,
                elapsed: const Duration(seconds: 0),
                onTap: () {
                  // For milestone 0, just jump straight to the Feedback screen.
                  Navigator.pushNamed(context, '/feedback');
                },
              ),

              const SizedBox(height: 24),

              Text(
                'Tap and say the word out loud.\n(Max 7 seconds)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
