import 'dart:convert';

class Attempt {
  final String uid; // 'student123' (fake for now)
  final String wordText; // 'ship'
  final int score; // 0-100
  final String feedback; // short text
  final DateTime createdAt; // when attempt saved
  final Duration duration; // length of recording

  Attempt({
    required this.uid,
    required this.wordText,
    required this.score,
    required this.feedback,
    required this.createdAt,
    required this.duration,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'wordText': wordText,
    'score': score,
    'feedback': feedback,
    'createdAt': createdAt.toIso8601String(),
    'durationMs': duration.inMilliseconds,
  };

  static Attempt fromMap(Map<String, dynamic> map) => Attempt(
    uid: map['uid'] as String,
    wordText: map['wordText'] as String,
    score: map['score'] as int,
    feedback: map['feedback'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
    duration: Duration(milliseconds: (map['durationMs'] as num).toInt()),
  );

  String toJson() => jsonEncode(toMap());
  static Attempt fromJson(String s) => fromMap(jsonDecode(s));
}
