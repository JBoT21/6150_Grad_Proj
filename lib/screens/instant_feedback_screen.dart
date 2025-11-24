// Screen that student sees immediately after attempting the word
// Screen design is dependant on whether the word was successfully pronounced or not

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:team_3_f25_project/models/wordlist.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class InstantFeedback extends StatefulWidget {
  bool success;
  WordList wordObject;
  InstantFeedback({super.key, required this.success, required this.wordObject});

  @override
  State<InstantFeedback> createState() => _InstantFeedbackState();
}

class _InstantFeedbackState extends State<InstantFeedback> {
  TextToSpeech textToSpeech = TextToSpeech();

  @override
  void initState() {
    super.initState();
    textToSpeech.initTts();
    textToSpeech
        .speak(widget.wordObject)
        .then(
          (_) => {
            {
              Timer(Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.pop(context);
                } else {
                  textToSpeech.stop();
                }
              }),
            },
          },
        );
  }

  @override
  void dispose() {
    super.dispose();
    textToSpeech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.success ? Colors.green : Colors.amber[600],
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 150.0, horizontal: 50.0),
          child: Center(
            child: Column(
              spacing: 25.0,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.wordObject.word,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 90.0,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black38, offset: Offset(1.5, 2)),
                      ],
                    ),
                  ),
                ),
                Icon(
                  widget.success ? Icons.check_rounded : Icons.close,
                  color: Colors.white,
                  size: 250,
                ),
                //FittedBox(
                //fit: BoxFit.fitWidth,
                //child:
                Text(
                  textAlign: TextAlign.center,
                  softWrap: true,
                  //overflow: TextOverflow.clip,
                  widget.wordObject.sentence1,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 45.0,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black38, offset: Offset(1.5, 2)),
                    ],
                  ),
                ),
                //),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextToSpeech {
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  dynamic initTts() {
    flutterTts = FlutterTts();

    Future<void> _getDefaultEngine() async {
      await flutterTts.getDefaultEngine;
    }

    Future<void> _getDefaultVoice() async {
      await flutterTts.getDefaultVoice;
    }

    Future<void> _setAwaitOptions() async {
      await flutterTts.awaitSpeakCompletion(true);
    }

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }
  }

  Future<void> speak(WordList wordObject) async {
    await flutterTts.setVolume(0.5);
    await flutterTts.setSpeechRate(0.3);
    await flutterTts.setPitch(1.6);

    await flutterTts.speak(wordObject.word);
    await Future.delayed(Duration(seconds: 1), () {
      flutterTts.speak(wordObject.sentence1);
    });
  }

  /*Future<void> _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future<void> _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }*/

  void stop() {
    flutterTts.stop();
  }
}
