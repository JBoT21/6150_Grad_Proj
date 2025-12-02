import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class FeedbackScreen extends StatelessWidget {
  final bool success;
  final String wordText;
  final String feedbackText;
  final String? studentRecording;

  const FeedbackScreen({
    super.key,
    required this.success,
    required this.wordText,
    required this.feedbackText,
    this.studentRecording,
  });

  @override
  Widget build(BuildContext context) {
    final audioPlayer = AudioPlayer();

    return Scaffold(
      backgroundColor: success ? Colors.green.shade100 : Colors.orange.shade100,
      appBar: AppBar(
        title: const Text(
          'Feedback',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: success
            ? Colors.green.shade400
            : Colors.orange.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Big icon and header message
            Icon(
              success ? Icons.star_rounded : Icons.refresh_rounded,
              color: success ? Colors.yellow.shade700 : Colors.orange.shade700,
              size: 120,
            ),
            const SizedBox(height: 20),
            Text(
              success ? 'Awesome Job!' : 'Good Try!',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: success ? Colors.green.shade800 : Colors.orange.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Word: $wordText',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              feedbackText,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Play recording buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (studentRecording != null) {
                      audioPlayer.play(DeviceFileSource(studentRecording!));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No student recording found!'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('My Voice'),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    // Placeholder for teacher’s pronunciation audio
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Teacher pronunciation coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const Text('Teacher Voice'),
                ),
              ],
            ),

            const SizedBox(height: 50),

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, 'tryAgain'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text('Try Again', style: TextStyle(fontSize: 18)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/wordlist_management'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text('Next Word', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
