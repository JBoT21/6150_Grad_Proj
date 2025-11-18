// Will read information about the list from seed_words.csv
// Also allows changes to be saved directly to csv file
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/wordlist.dart';

class WordService {
  static String? _csvPath;

  // Check for writable CSV file
  static Future<String> _getCSVPath() async {
    if (_csvPath != null) return _csvPath!;

    try {
      final dir = await getApplicationDocumentsDirectory();
      //print('Documents directory: ${dir.path}');
      final path = '${dir.path}/seed_words.csv';

      final file = File(path);
      if (!await file.exists()) {
        // copy the file from assets
        final data = await rootBundle.loadString('lib/data/seed_words.csv');
        await file.writeAsString(data);
      }

      _csvPath = path;
      return _csvPath!;
    } catch (e) {
      print('failed to get csv path: $e');
      rethrow;
    }
  }

  // Gets all words from the csv file
  static Future<List<WordList>> loadWords() async {
    final path = await _getCSVPath();
    final csvData = await File(path).readAsString();
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

  // Gets the words by list
  static Future<List<WordList>> getWords(int listId) async {
    final allWords = await loadWords();
    return allWords.where((w) => w.listId == listId).toList();
  }

  // Get the list id
  static Future<List<int>> getListIds() async {
    final allWords = await loadWords();
    return allWords.map((w) => w.listId).toSet().toList();
  }

  // Gets the category
  static Future<String> getCategory(int listId) async {
    final allWords = await loadWords();
    return allWords.firstWhere((w) => w.listId == listId).category;
  }

  // Updates the priority
  static Future<void> updateListPriority(int listId, int newPriority) async {
    final path = await _getCSVPath();
    //print('Updating CSV at $path');
    final allWords = await loadWords();
    for (var word in allWords) {
      if (word.listId == listId) {
        word.priority = newPriority;
      }
    }

    // Rebuild CSV
    final header =
        'id,list_id,priority,category,word,sentence1,sentence2,sentence3';
    final csvLines = [header];
    for (var w in allWords) {
      csvLines.add(
        '${w.id},${w.listId},${w.priority},${w.category},${w.word},${w.sentence1},${w.sentence2},${w.sentence3}',
      );
    }

    await File(path).writeAsString(csvLines.join('\n'));
    //print('CSV updated at $path');
  }

  // Gets the top priority
  static Future<int> getTopPriority() async {
    final allWords = await loadWords();

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
    return topListId!;
  }
}
