import 'package:flutter/material.dart';
import '../services/list_service.dart';
import '../models/wordlist.dart';

class AddWordlistScreen extends StatefulWidget {
  const AddWordlistScreen({super.key});

  @override
  State<AddWordlistScreen> createState() => _AddWordlistScreenState();
}

class _AddWordlistScreenState extends State<AddWordlistScreen> {
  final TextEditingController _titleController = TextEditingController();
  List<WordWithSentences> words = [];

  void _addWordDialog() {
    final wordCtrl = TextEditingController();
    final s1Ctrl = TextEditingController();
    final s2Ctrl = TextEditingController();
    final s3Ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Word"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: wordCtrl, decoration: const InputDecoration(labelText: "Word")),
              TextField(controller: s1Ctrl, decoration: const InputDecoration(labelText: "Sentence 1")),
              TextField(controller: s2Ctrl, decoration: const InputDecoration(labelText: "Sentence 2")),
              TextField(controller: s3Ctrl, decoration: const InputDecoration(labelText: "Sentence 3")),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (wordCtrl.text.isNotEmpty &&
                  s1Ctrl.text.isNotEmpty &&
                  s2Ctrl.text.isNotEmpty &&
                  s3Ctrl.text.isNotEmpty) {
                setState(() {
                  words.add(WordWithSentences(
                    word: wordCtrl.text.trim(),
                    sentence1: s1Ctrl.text.trim(),
                    sentence2: s2Ctrl.text.trim(),
                    sentence3: s3Ctrl.text.trim(),
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  /// Import CSV
  Future<void> _importCSV() async {
    final imported = await WordService.importCSV();

    if (imported == null || imported.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No CSV found or file empty.")),
      );
      return;
    }

    setState(() {
      words.addAll(imported);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Imported ${imported.length} words.")),
    );
  }

  /// SAVE LIST
  Future<void> _saveList() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("List Title is required")),
      );
      return;
    }
    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least 1 word")),
      );
      return;
    }

    await WordService.addListOfWords(
      words,
      _titleController.text.trim(),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Create Word List"),
      backgroundColor: Colors.blueAccent,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Import CSV File
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _importCSV,
                icon: const Icon(Icons.upload_file),
                label: const Text("Import Wordlist CSV"),
              ),
            ),

            const SizedBox(height: 8),

            // Text box below import option
            Center(
              child: Text(
                "CSV format is word,sentence1,sentence2,sentence3 Or enter the word list manually below",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // List Entry
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "List Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // Add words
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _addWordDialog,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Word"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // manually added words
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: words.length,
              itemBuilder: (_, i) {
                final w = words[i];
                return Card(
                  child: ListTile(
                    title: Text(w.word),
                    subtitle: Text(w.sentence1),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => words.removeAt(i)),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Save updated list
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveList,
                child: const Text("Save Word List"),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
