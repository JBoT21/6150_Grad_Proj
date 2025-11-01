import 'package:flutter/material.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';
import 'package:team_3_f25_project/widgets/word_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/screens/login.dart';

class WordlistSelectionScreen extends StatelessWidget {
  const WordlistSelectionScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wordlist Selection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          WordCard(
            wordText: "List 1",
            patternLabel: "Word 1, Word 2..",
            sampleSentence: "",
          ),
          WordCard(
            wordText: "List 2",
            patternLabel: "Word 1, Word 2..",
            sampleSentence: "",
            onPractice: () {},
          ),
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
                Navigator.pushNamed(context, "/wordlist_screen");
              },
              child: Text("Select wordlist"),
            ),
          ],
        ),
      ),
    );
  }
}
