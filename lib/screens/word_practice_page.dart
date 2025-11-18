import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:team_3_f25_project/models/wordlist.dart';
import 'package:team_3_f25_project/screens/wordlist_screen.dart';
import 'package:team_3_f25_project/services/list_service.dart';
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

class WordPracticeScreen extends StatefulWidget {
  final db = DatabaseHelper.instance;
  WordPracticeScreen({super.key});

  @override
  State<WordPracticeScreen> createState() => _WordPracticeScreenState();
}

class _WordPracticeScreenState extends State<WordPracticeScreen> {
  // variables to keep track of progress
  SharedPreferences? prefs;
  int? userId;
  int? currentListId;
  List<WordList>? completeWordList;
  List<String>? wordsToPractice;
  int nextIndex = 0;

  String get currentWord {
    if (wordsToPractice == null || wordsToPractice!.isEmpty) return '';
    return wordsToPractice![nextIndex];
  }

  bool _loading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // variables for recording / listening
  final _speechToText = SpeechToText();
  final _recorder = AudioRecorder();
  int correctlyPronounced = 0;
  String recordingPath = "";
  bool _speechEnabled = false;
  bool _isListening = false;

  Duration _elapsed = Duration.zero;
  Timer? _timer;
  static const Duration kMax = Duration(seconds: 7);

  @override
  void initState() {
    super.initState();
    _loadUserAndWords();
    _initSpeech();
  }

  Future<void> _loadUserAndWords() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      // gets shared preferences to load user data and see user progress
      prefs = await SharedPreferences.getInstance();
      userId = prefs!.getInt('userId');

      // get list
      currentListId = prefs!.getInt('currentListId');
      print(currentListId);
      completeWordList = await WordService.getWords(currentListId!);

      // find and remove words user has gotten correct in the past
      final allAttempts = await widget.db.database.then(
        (db) => db.query('attempts'),
      );
      print(allAttempts.where((a) => a['uid'] == userId));
      final correctWords = allAttempts
          .where((a) => a['score'] == 1 && a['uid'] == userId)
          .map((a) => a['wordText'] as String)
          .toSet();

      // initialize list
      wordsToPractice = completeWordList!.map((entry) => entry.word).toList();
      wordsToPractice!.removeWhere((word) => correctWords.contains(word));
      correctlyPronounced = completeWordList!.length - wordsToPractice!.length;
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _nextWord() {
    setState(() {
      nextIndex = nextIndex % completeWordList!.length;
    });
  }

  void _removeWordFromList() {
    if (wordsToPractice!.isNotEmpty) {
      wordsToPractice!.remove(currentWord);
    }
  }

  void _finishList() {
    // TODO get number of lists and have special celebration screen for
    // when all lists are completed
    int nextListId = currentListId! + 1 % 5;
    prefs!.setInt('currentListId', nextListId);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CelebrationScreen(nextListId: nextListId),
      ),
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
    print(recognizedWord);
    return recognizedWord.toLowerCase() == currentWord.toLowerCase();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      _stopListening();
      bool correct = _isCorrect(result.recognizedWords);

      userId ??= -1;;
      // add attempt to database
      widget.db
          .insertAttempt(
            Attempt(
              uid: userId!,
              wordText: currentWord,
              score: correct ? 1 : 0,
              createdAt: DateTime.now(),
              feedback: correct ? "Great job" : "Try again",
              recordingPath: recordingPath,
              duration: _elapsed,
            ),
          )
          .then((_) => print('User ID SUCCESS: $userId'));

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
        if (correctlyPronounced == completeWordList!.length) {
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

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueGrey),
      );
    }

    // Error state
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadUserAndWords,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state - no words to practice
    if (wordsToPractice == null || wordsToPractice!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'No words to practice!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('You\'ve mastered all words in this list!'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _finishList,
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }

    // ✅ Main content - now safe to access wordsToPractice
    return Center(
      child: Column(
        children: [
          LinearProgressIndicator(
            value:
                correctlyPronounced /
                (correctlyPronounced + wordsToPractice!.length),
            color: Colors.green,
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Progress: $correctlyPronounced / ${completeWordList!.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          WordCard(
            wordText: currentWord,
            patternLabel: "Pattern label",
            sampleSentence: "Sample sentence",
          ),
          const SizedBox(height: 50),
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
          if (_isListening)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                '${_elapsed.inSeconds}s / ${kMax.inSeconds}s',
                style: const TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: "Word Practice Screen"),
      body: _buildBody(),
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
  final nextListId;
  const CelebrationScreen({super.key, required this.nextListId});

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

              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProgressScreen(listId: nextListId),
                    ),
                  );
                },
                child: Icon(
                  Icons.arrow_circle_right,
                  size: 100,
                  color: Colors.yellow.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
