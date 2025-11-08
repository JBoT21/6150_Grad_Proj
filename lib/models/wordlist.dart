import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

// Class for word list
class WordList {
  final int id;
  final int listId;
  final String category;
  final String word;
  final String sentence1;
  final String sentence2;
  final String sentence3;

  // Word list constructor
  WordList({
    required this.id,
    required this.listId,
    required this.category,
    required this.word,
    required this.sentence1,
    required this.sentence2,
    required this.sentence3,
  });

  factory WordList.fromCSV(List<dynamic> type) {
    return WordList(
      id: int.parse(type[0]),
      listId: int.parse(type[1]),
      category: type[2],
      word: type[3],
      sentence1: type[4],
      sentence2: type[5],
      sentence3: type[6],
    );
  }
}
