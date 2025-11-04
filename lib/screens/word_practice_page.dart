import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/attempt.dart';
import '../services/attempts_repository.dart';
import '../models/progress_view_model.dart'; // so we can refresh after save (optional)
import '../widgets/record_button.dart';
import '../routes.dart';

class WordPracticeScreen extends StatefulWidget {
  final String wordText;
  final String sampleSentence;
  final String uid; // pass real auth uid later; using demo for now

  const WordPracticeScreen({
    super.key,
    this.wordText = 'ship',                // sane defaults for dev/demo
    this.sampleSentence = 'The ship is big.',
    this.uid = 'demoStudent',
  });

  @override
  State<WordPracticeScreen> createState() => _WordPracticeScreenState();
}

class _WordPracticeScreenState extends State<WordPracticeScreen> {
  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  static const Duration kMax = Duration(seconds: 7);

  void _startRecording() {
    if (_isRecording) return;
    setState(() {
      _isRecording = true;
      _elapsed = Duration.zero;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      final next = _elapsed + const Duration(milliseconds: 200);
      if (next >= kMax) {
        _stopRecording(autoStop: true);
      } else {
        setState(() {
          _elapsed = next;
        });
      }
    });
  }

  Future<void> _stopRecording({bool autoStop = false}) async {
    if (!_isRecording) return;
    _timer?.cancel();
    setState(() {
      _isRecording = false;
    });

    // ---- Local "STT compare" stub ----
    // Deterministic pseudo-score based on the word so demos look consistent.
    final int score = _deterministicScore(widget.wordText);
    final String feedback = _makeFeedback(widget.wordText, score);

    // Save attempt locally
    final attempt = Attempt(
      uid: widget.uid,
      wordText: widget.wordText,
      score: score,
      feedback: feedback,
      createdAt: DateTime.now(),
      duration: _elapsed,
    );
    final repo = AttemptsRepository();
    await repo.add(attempt);

    // Optional: refresh progress VM if it's already in memory
    if (mounted) {
      final vm = context.read<ProgressViewModel?>();
      vm?.load();
    }

    // Navigate to Feedback (if your Feedback screen reads arguments, pass them)
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.feedback,
      arguments: {
        'wordText': widget.wordText,
        'score': score,
        'feedback': feedback,
      },
    );
  }

  // Simple deterministic score using a hash on word.
  int _deterministicScore(String word) {
    int sum = 0;
    for (final code in word.codeUnits) {
      sum = (sum + code) % 1000;
    }
    // Map to 60..98 range, looks believable for demo
    final s = 60 + (sum % 39);
    return s.clamp(0, 100);
  }

  String _makeFeedback(String word, int score) {
    if (word.contains('sh')) {
      return score >= 80
          ? 'Great /ʃ/ sound on "$word"!'
          : 'Work on the /ʃ/ in "$word". Try a slower start.';
    }
    if (word.contains('th')) {
      return score >= 80
          ? 'Nice /θ/ in "$word".'
          : 'Watch your /θ/ in "$word" — tongue slightly between teeth.';
    }
    return score >= 80
        ? 'Good clarity on "$word".'
        : 'Say "$word" a bit slower and hit the ending sound.';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Practice: "${widget.wordText}"')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Word + example sentence
                Text(
                  widget.wordText,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.sampleSentence,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 28),

                // Big mic button
                RecordButton(
                  isRecording: _isRecording,
                  elapsed: _elapsed,
                  onTap: () {
                    _isRecording ? _stopRecording() : _startRecording();
                  },
                ),

                const SizedBox(height: 16),
                Text(
                  'Max 7 seconds • Local compare (stub) → Feedback',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),

                if (_isRecording) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Listening...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                if (!_isRecording && _elapsed > Duration.zero) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _stopRecording,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Finish & Get Feedback'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
