import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/models/attempt.dart';
import 'package:team_3_f25_project/models/game_session.dart';
import 'package:team_3_f25_project/services/list_service.dart';
import 'package:team_3_f25_project/services/text_to_speech.dart';
import 'package:team_3_f25_project/services/user_db.dart';
import 'package:team_3_f25_project/widgets/bouncing_balloon_arena.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';

const _maxRoundsPerSession = 15;
const _pointsPerPop = 10;
final _balloonColors = [
  Colors.redAccent,
  Colors.blueAccent,
  Colors.green,
  Colors.orange,
];

class BalloonPopScreen extends StatefulWidget {
  final int listId;
  const BalloonPopScreen({super.key, required this.listId});

  @override
  State<BalloonPopScreen> createState() => _BalloonPopScreenState();
}

class _BalloonPopScreenState extends State<BalloonPopScreen> {
  final db = DatabaseHelper.instance;
  final TextToSpeech _tts = TextToSpeech();
  final Random _random = Random();

  int? userId;
  bool _loading = true;
  bool _sessionComplete = false;

  List<String> _roundWords = [];
  List<String> _allWords = [];
  int _roundIndex = 0;
  String _targetWord = '';
  List<String> _balloonWords = [];
  String? _shakingWord;
  String? _poppedWord;

  int _score = 0;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _tts.initTts();
    _loadGame();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');

    final words = await WordService.getWords(widget.listId);
    _allWords = words.map((w) => w.word).toList();

    final shuffled = List<String>.from(_allWords)..shuffle(_random);
    _roundWords = shuffled.take(_maxRoundsPerSession).toList();

    if (!mounted) return;
    setState(() => _loading = false);

    if (_roundWords.isNotEmpty) {
      _startRound();
    } else {
      setState(() => _sessionComplete = true);
    }
  }

  void _startRound() {
    _targetWord = _roundWords[_roundIndex];

    final distractorPool = _allWords.where((w) => w != _targetWord).toList()
      ..shuffle(_random);
    final distractors = distractorPool.take(3).toList();

    final balloons = [_targetWord, ...distractors]..shuffle(_random);

    setState(() {
      _balloonWords = balloons;
      _shakingWord = null;
      _poppedWord = null;
    });

    _tts.speak('$_targetWord.');
  }

  Future<void> _onBalloonTap(String word) async {
    if (_poppedWord != null) return;

    final correct = word == _targetWord;

    await db.insertAttempt(
      Attempt(
        uid: userId,
        wordText: _targetWord,
        listId: widget.listId,
        score: correct ? 1 : 0,
        createdAt: DateTime.now(),
        feedback: correct ? 'Popped!' : 'Try again',
        recordingPath: '',
        duration: Duration.zero,
        source: 'balloon_pop',
      ),
    );

    if (correct) {
      _score += _pointsPerPop;
      _correctCount++;
      setState(() => _poppedWord = word);
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      _roundIndex++;
      if (_roundIndex >= _roundWords.length) {
        _endSession();
      } else {
        _startRound();
      }
    } else {
      setState(() => _shakingWord = word);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _shakingWord = null);
      });
    }
  }

  Future<void> _endSession() async {
    await db.insertGameSession(
      GameSession(
        uid: userId,
        listId: widget.listId,
        score: _score,
        totalWords: _roundWords.length,
        correctWords: _correctCount,
        createdAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    setState(() => _sessionComplete = true);
  }

  int get _stars {
    if (_roundWords.isEmpty) return 0;
    final accuracy = _correctCount / _roundWords.length;
    if (accuracy >= 0.9) return 3;
    if (accuracy >= 0.7) return 2;
    if (accuracy >= 0.5) return 1;
    return 0;
  }

  Widget _buildSummary() {
    final total = _roundWords.length;
    final accuracy = total == 0 ? 0.0 : _correctCount / total;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final filled = i < _stars;
                return Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 64,
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: $_score',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(accuracy * 100).toStringAsFixed(0)}% correct ($_correctCount/$total)',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Round ${_roundIndex + 1}/${_roundWords.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Score: $_score',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BouncingBalloonArena(
              words: _balloonWords,
              colors: _balloonColors,
              poppedWord: _poppedWord,
              shakingWord: _shakingWord,
              onTap: _onBalloonTap,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _tts.speak('$_targetWord.'),
            icon: const Icon(Icons.volume_up),
            label: const Text('Hear the word again'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: customAppBar(context: context, title: 'Balloon Pop'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_sessionComplete ? _buildSummary() : _buildGame()),
      ),
    );
  }
}
