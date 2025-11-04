import 'dart:convert';

class Attempt {
  final String uid; // 'student123' (fake for now)
  final String word; // 'ship'
  final int score; // 0-100
  final String speechToTextResult; // short text
  final DateTime createdAt; // when attempt saved// length of recording

  Attempt({
    required this.uid,
    required this.word,
    required this.score,
    required this.speechToTextResult,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'word': word,
    'score': score,
    'speechToTextResult': speechToTextResult,
    'createdAt': createdAt.toIso8601String(),
  };

  static Attempt fromMap(Map<String, dynamic> map) => Attempt(
    uid: map['uid'] as String,
    word: map['word'] as String,
    score: map['score'] as int,
    speechToTextResult: map['speechToTextResult'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
  );

  String toJson() => jsonEncode(toMap());
  static Attempt fromJson(String s) => fromMap(jsonDecode(s));
}
