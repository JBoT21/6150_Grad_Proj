import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:team_3_f25_project/models/wordlist.dart';
import 'package:team_3_f25_project/screens/wordlist_selection.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';
import 'package:team_3_f25_project/widgets/record_button.dart';
import 'package:team_3_f25_project/widgets/word_card.dart';
import 'package:team_3_f25_project/models/attempt.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:team_3_f25_project/services/user_db.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/screens/login.dart';

class WordPracticeScreen extends StatefulWidget {
  final List<WordList> words;

  final db = DatabaseHelper.instance;
  WordPracticeScreen({super.key, required this.words});

  @override
  State<WordPracticeScreen> createState() => _WordPracticeScreenState();
}

class _WordPracticeScreenState extends State<WordPracticeScreen> {
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  int nextIndex = 0;

  final _speechToText = SpeechToText();
  final _recorder = AudioRecorder();
  int correctlyPronounced = 0;
  String recordingPath = "";
  bool _speechEnabled = false;
  bool _isListening = false;

  Duration _elapsed = Duration.zero;
  Timer? _timer;
  static const Duration kMax = Duration(seconds: 7);

  String get currentWord {
    return widget.words[nextIndex].word;
  }

  WordList get currentWordEntry {
    return widget.words[nextIndex];
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
      nextIndex = (nextIndex + 1) % widget.words.length;
    });
  }

  void _removeWordFromList() {
    if (widget.words.isNotEmpty) {
      widget.words.remove(currentWordEntry);
    }
  }

  void _finishList() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CelebrationScreen()),
    );
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
      _stopListening();
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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InstantFeedback(success: correct),
        ),
      ).then((_) {
        if (correct) {
          correctlyPronounced++;
          _removeWordFromList();
        }
        if (widget.words.isEmpty) {
          _finishList();
        } else {
          _nextWord();
        }
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
            LinearProgressIndicator(
              value:
                  correctlyPronounced /
                  (correctlyPronounced + widget.words.length),
              value: (nextIndex + 1) / widget.wordlist.length,
              color: Colors.green,
              backgroundColor: Colors.grey.shade300,
            ),
            WordCard(
              wordText: currentWord,
              patternLabel: "Pattern label",
              sampleSentence: "Sample sentence",
            ),
            SizedBox(height: 50),
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
          ],
        ),
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

class CelebrationScreen extends StatelessWidget {
  const CelebrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(centerTitle: true, backgroundColor: Colors.green.shade400),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Big icon and header message
              Icon(
                Icons.star_rounded,
                color: Colors.yellow.shade700,
                size: 250,
              ),
              const SizedBox(height: 20),
              Text(
                'Awesome Job!',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              const SizedBox(height: 30),

              // TODO change to getting next priority list
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WordlistSelectionScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.arrow_circle_right,
                  size: 100,
                  color: Colors.purple.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
