import 'package:flutter/material.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';
import 'package:team_3_f25_project/widgets/word_card.dart';
import 'package:team_3_f25_project/models/wordlist.dart';

class WordlistScreen extends StatelessWidget {
  final String category;
  final List<WordList> words;

  const WordlistScreen({
    super.key,
    required this.category,
    required this.words,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: category),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: words.length,
        itemBuilder: (context, index) {
          final w = words[index];
          return WordCard(
            wordText: w.word,
            patternLabel: '',
            sampleSentence: w.sentence1,
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/progress');
              },
              child: const Text('View Progress'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/practice');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Practice Wordlist'),
            ),
          ],
        ),
      ),
    );
  }
}
