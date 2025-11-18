//import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:team_3_f25_project/screens/word_practice_page.dart';
import 'package:team_3_f25_project/screens/wordlist_screen.dart';
//import 'package:team_3_f25_project/widgets/custom_app_bar.dart';
//import 'package:team_3_f25_project/widgets/word_card.dart';
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
  List<Map<String, dynamic>> wordlists = [];

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _loadWordLists() async {
    final listIds = await WordService.getListIds();
    final lists = <Map<String, dynamic>>[];

    for (var id in listIds) {
      final category = await WordService.getCategory(id);
      final words = await WordService.getWords(id);
      final priority = words.isNotEmpty ? words.first.priority : 100;
      lists.add({
        'id': id,
        'category': category,
        'words': words,
        'priority': priority,
      });
    }

    // Sort by priority
    lists.sort((a, b) => a['priority'].compareTo(b['priority']));
    setState(() => wordlists = lists);
  }

  Future<void> _updatePriorities() async {
    for (int i = 0; i < wordlists.length; i++) {
      final listId = wordlists[i]['id'];
      await WordService.updateListPriority(listId, i + 1);
      await WordService.updateListPriority(listId, i + 1);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadWordLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Wordlists",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: wordlists.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ReorderableListView(
                    padding: const EdgeInsets.all(16),
                    onReorder: (oldIndex, newIndex) async {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = wordlists.removeAt(oldIndex);
                        wordlists.insert(newIndex, item);
                      });
                      await _updatePriorities();
                    },
                    children: [
                      for (final list in wordlists)
                        Card(
                          key: ValueKey(list['id']),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              list['category'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              list['words']
                                  .take(5)
                                  .map((w) => w.word)
                                  .join(', '),
                            ),
                            trailing: const Icon(Icons.drag_handle),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProgressScreen(listId: list['id']),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Drag and drop to reorder list priority (Top = highest priority)",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
    );
  }
}
