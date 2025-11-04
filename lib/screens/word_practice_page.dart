import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:team_3_f25_project/routes.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';
import 'package:team_3_f25_project/widgets/record_button.dart';
import 'package:team_3_f25_project/widgets/word_card.dart';
import 'package:team_3_f25_project/models/attempt.dart';
import 'package:record/record.dart';
import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:team_3_f25_project/services/user_db.dart';
import 'package:speech_to_text/speech_to_text.dart';

class WordPracticeScreen extends StatefulWidget {
  final List<String> wordlist = [
    'cat',
    'pen',
    'cut',
    'van',
    'nap',
    'tap',
    'bed',
  ];
  final db = DatabaseHelper.instance;
  WordPracticeScreen({super.key});

  @override
  State<WordPracticeScreen> createState() => _WordPracticeScreenState();
}

class _WordPracticeScreenState extends State<WordPracticeScreen> {
  int nextIndex = 0;

  final _speechToText = SpeechToText();
  final _recorder = AudioRecorder();
  String recordingPath = "";
  bool _speechEnabled = false;
  bool _isListening = false;

  Duration _elapsed = Duration.zero;
  Timer? _timer;
  static const Duration kMax = Duration(seconds: 7);

  String get currentWord {
    return widget.wordlist[nextIndex];
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _nextWord() {
    setState(() {
      nextIndex = (nextIndex + 1) % widget.wordlist.length;
    });
    print(currentWord);
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'en_US', // Specify the locale
      listenFor: const Duration(seconds: 7), // How long to listen
      pauseFor: const Duration(seconds: 2), // How long to wait for pause
    );
    final config = RecordConfig(
      encoder: AudioEncoder.aacLc, // -> .m4a
      sampleRate: 44100,
      bitRate: 128000,
    );
    recordingPath = await _nextPath();
    await _recorder.start(config, path: recordingPath);
    setState(() {
      _isListening = true;
      _elapsed = Duration.zero;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      final next = _elapsed + const Duration(milliseconds: 200);
      if (next >= kMax) {
        _stopListening();
      } else {
        setState(() {
          _elapsed = next;
        });
      }
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    _timer?.cancel();
    setState(() {
      _isListening = false;
    });
  }

  bool _isCorrect(String recognizedWord) {
    return recognizedWord.toLowerCase() == currentWord.toLowerCase();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      bool correct = _isCorrect(result.recognizedWords);
      // add attempt to database
      widget.db.insertAttempt(
        Attempt(
          uid: "INSERT",
          wordText: currentWord,
          score: correct ? 1 : 0,
          createdAt: DateTime.now(),
          feedback: correct ? "Great job" : "Try again",
          recordingPath: recordingPath,
          duration: _elapsed,
        ),
      );

      // show feedback
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InstantFeedback(success: correct),
        ),
      ).then((_) {
        correct ? _nextWord() : null;
      });
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  Future<String> _nextPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}/readright_$currentWord$ts.m4a';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: "Word Practice Screen"),
      body: Center(
        child: Column(
          children: [
            WordCard(
              wordText: currentWord,
              patternLabel: "Pattern label",
              sampleSentence: "Sample sentence",
            ),
            SizedBox(height: 30),
            RecordButton(
              isRecording: _isListening,
              onTap: _speechEnabled
                  ? () {
                      if (_isListening) {
                        _stopListening();
                      } else {
                        _startListening();
                      }
                    }
                  : null,
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber.shade200,
        label: Icon(
          Icons.arrow_right_alt_rounded,
          color: Colors.amber.shade800,
          size: 45,
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.feedback,
            arguments: {
              'wordText': currentWord,
              'score': 1,
              'feedback': "feedback",
            },
          );
        },
      ),
    );
  }
}

class InstantFeedback extends StatefulWidget {
  bool success;
  InstantFeedback({super.key, required this.success});

  @override
  State<InstantFeedback> createState() => _InstantFeedbackState();
}

class _InstantFeedbackState extends State<InstantFeedback> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 2), () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: widget.success ? Colors.green : Colors.amber[600],
        child: Center(
          child: Icon(
            widget.success ? Icons.check_rounded : Icons.refresh_rounded,
            color: Colors.white,
            size: 250,
          ),
        ),
      ),
    );
  }
}

class TryAgain extends StatefulWidget {
  const TryAgain({super.key});

  @override
  State<TryAgain> createState() => _TryAgainState();
}

class _TryAgainState extends State<TryAgain> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 2), () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.amber.shade600,
        child: Center(
          child: Icon(Icons.refresh_rounded, color: Colors.white, size: 250),
        ),
      ),
    );
  }
}
