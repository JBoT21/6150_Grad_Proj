import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:team_3_f25_project/screens/word_practice_page.dart';
import 'package:team_3_f25_project/screens/wordlist_screen.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';
import 'package:team_3_f25_project/widgets/word_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/screens/login.dart';
import 'package:team_3_f25_project/services/list_service.dart';
import 'package:team_3_f25_project/models/wordlist.dart';

class WordlistSelectionScreen extends StatefulWidget {
  const WordlistSelectionScreen({super.key});

  @override
  State<WordlistSelectionScreen> createState() => _WordlistSelectionState();
}

class _WordlistSelectionState extends State<WordlistSelectionScreen> {
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
        title: const Text(
          "Select Your Wordlist",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<List<int>>(
        future: WordService.getListIds(),
        builder: (context, snapshot) {
          //if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading wordlists: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No wordlists found'));
          }

          final listIds = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: listIds.map((id) {
              return FutureBuilder<String>(
                future: WordService.getCategory(id),
                builder: (context, catSnapshot) {
                  //if (!catSnapshot.hasData) return const SizedBox();
                  if (catSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  } else if (catSnapshot.hasError) {
                    return Text('Error loading category: ${catSnapshot.error}');
                  }

                  final category = catSnapshot.data!;
                  return FutureBuilder<List<WordList>>(
                    future: WordService.getWords(id),
                    builder: (context, wordSnapshot) {
                      if (!wordSnapshot.hasData) return const SizedBox();

                      final words = wordSnapshot.data!;
                      final wordPreview = words
                          .take(5)
                          .map((w) => w.word)
                          .join(', ');

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                wordPreview,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              WordPracticeScreen(words: words),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightBlueAccent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: const Text('Practice'),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.blueAccent,
                                      size: 32,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => WordlistScreen(
                                            category: category,
                                            words: words,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
