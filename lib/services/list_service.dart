// Will read information about the list from seed_words.csv
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/wordlist.dart';

class WordService {
  static Future<List<WordList>> loadWords() async {
    final csvData = await rootBundle.loadString('lib/data/seed_words.csv');
    final lines = const LineSplitter().convert(csvData);
    final List<WordList> words = [];

    for (int i = 1; i < lines.length; i++) {
      final row = lines[i].split(',');
      if (row.length >= 7) {
        words.add(WordList.fromCSV(row));
      }
    }

    return words;
  }

  static Future<List<WordList>> getWords(int listId) async {
    final allWords = await loadWords();
    return allWords.where((w) => w.listId == listId).toList();
  }

  static Future<List<int>> getListIds() async {
    final allWords = await loadWords();
    return allWords.map((w) => w.listId).toSet().toList();
  }

  static Future<String> getCategory(int listId) async {
    final allWords = await loadWords();
    return allWords.firstWhere((w) => w.listId == listId).category;
  }
}
