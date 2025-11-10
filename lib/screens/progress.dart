import 'package:flutter/material.dart';
import '../services/user_db.dart';
import '../services/list_service.dart';
import '../models/attempt.dart';

class ProgressScreen extends StatefulWidget {
  final int listId; // which word list this progress screen shows
  const ProgressScreen({super.key, required this.listId});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final db = DatabaseHelper.instance;
  double completion = 0;
  int totalWords = 0;
  int masteredWords = 0;
  List<Map<String, dynamic>> wordStatus = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final words = await WordService.getWords(widget.listId);
    final allAttempts = await db.database.then((db) => db.query('attempts'));

    // Get list of correctly scored words
    final correctWords = allAttempts
        .where((a) => a['score'] == 1)
        .map((a) => a['wordText'] as String)
        .toSet();

    setState(() {
      totalWords = words.length;
      masteredWords = words.where((w) => correctWords.contains(w.word)).length;
      completion = totalWords == 0 ? 0 : masteredWords / totalWords;

      // Map each word to its progress state
      wordStatus = words.map((w) {
        bool correct = correctWords.contains(w.word);
        return {
          'word': w.word,
          'status': correct ? 'mastered' : 'pending',
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text('Your Progress'),
        backgroundColor: Colors.lightBlue.shade400,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Word List ${widget.listId}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You’ve mastered $masteredWords of $totalWords words!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),

            // Circular progress bar
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: completion,
                    strokeWidth: 14,
                    color: Colors.greenAccent.shade400,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  Text(
                    '${(completion * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView.builder(
                itemCount: wordStatus.length,
                itemBuilder: (context, index) {
                  final word = wordStatus[index]['word'];
                  final status = wordStatus[index]['status'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: status == 'mastered'
                        ? Colors.green.shade100
                        : Colors.white,
                    child: ListTile(
                      leading: Icon(
                        status == 'mastered'
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: status == 'mastered'
                            ? Colors.green
                            : Colors.grey,
                        size: 32,
                      ),
                      title: Text(
                        word,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(status == 'mastered'
                          ? 'You got it right!'
                          : 'Not yet practiced'),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/practice'),
                  icon: const Icon(Icons.mic),
                  label: const Text('Practice Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade300,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/wordlist_selection'),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next List'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade300,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
