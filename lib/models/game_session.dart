class GameSession {
  final int? uid;
  final int listId;
  final int score;
  final int totalWords;
  final int correctWords;
  final DateTime createdAt;

  GameSession({
    required this.uid,
    required this.listId,
    required this.score,
    required this.totalWords,
    required this.correctWords,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'listId': listId,
    'score': score,
    'totalWords': totalWords,
    'correctWords': correctWords,
    'createdAt': createdAt.toIso8601String(),
  };
}
