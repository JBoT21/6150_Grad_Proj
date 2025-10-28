import 'package:flutter/material.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';
import 'package:team_3_f25_project/widgets/record_button.dart';
import 'package:team_3_f25_project/widgets/word_card.dart';

class WordPracticeScreen extends StatelessWidget {
  const WordPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: "Word Practice Screen"),
      body: Center(
        child: Column(
          children: [
            WordCard(
              wordText: "Word",
              patternLabel: "Pattern label",
              sampleSentence: "Sample sentence",
            ),
            RecordButton(isRecording: true),
          ],
        ),
      ),
    );
  }
}
