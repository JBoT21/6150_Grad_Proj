import 'package:flutter/material.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';
import 'package:team_3_f25_project/widgets/word_card.dart';

class WordlistScreen extends StatelessWidget {
  const WordlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: "Wordlist Screen"),
      body: ListView(
        children: [
          WordCard(wordText: "Word 1", patternLabel: "", sampleSentence: ""),
          WordCard(wordText: "Word 2", patternLabel: "", sampleSentence: ""),
        ],
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/progress");
              },
              child: Text("View progress"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/practice");
              },
              child: Text("Practice wordlist"),
            ),
          ],
        ),
      ),
    );
  }
}
