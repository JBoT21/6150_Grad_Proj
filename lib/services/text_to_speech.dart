import 'package:flutter_tts/flutter_tts.dart';
import 'package:team_3_f25_project/models/wordlist.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

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

    flutterTts.setLanguage("en-US");

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

    // punctuation helps it sound more natural, allegedly
    await flutterTts.speak("${wordObject.word}.");
    await Future.delayed(Duration(seconds: 1), () {
      flutterTts.speak(wordObject.sentence1);
    });
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }
}
