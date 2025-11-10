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

  static Future<void> updateListPriority(int listId, int newPriority) async {
    final allWords = await getWords(listId);
    for (final word in allWords) {
      word.priority = newPriority;
    }
    //await saveWordsToCsv(listId, allWords);
  }

  static Future<int?> getTopPriority() async {
    final allWords = await loadWords();
    if (allWords.isEmpty) return null;

    // Only get priority 1 time per list
    final Map<int, int> listPriorities = {};
    for (var w in allWords) {
      listPriorities[w.listId] = w.priority;
    }

    // Find priority 1
    int? topListId;
    int minPriority = 100;
    listPriorities.forEach((listId, priority) {
      if (priority < minPriority) {
        minPriority = priority;
        topListId = listId;
      }
    });
    return topListId;
  } 
}
