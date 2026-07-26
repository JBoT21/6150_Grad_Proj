import 'package:flutter/material.dart';
import '../services/openai_service.dart';

class StoryBuilderScreen extends StatefulWidget {
  const StoryBuilderScreen({super.key});

  @override
  State<StoryBuilderScreen> createState() => _StoryBuilderScreenState();
}

class _StoryBuilderScreenState extends State<StoryBuilderScreen> {
  final TextEditingController _promptController = TextEditingController();

  bool _isLoading = false;
  String _story = "";

  Future<void> _generateStory() async {
    final prompt = _promptController.text.trim();

    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a story idea."),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _story = "";
    });

    try {
      final story = await OpenAIService.generateStory(prompt);

      setState(() {
        _story = story;
      });
    } catch (e) {
      setState(() {
        _story = "Error generating story.\n\n$e";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Story Builder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: _promptController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "What should the story be about?",
                hintText:
                "Example: A dragon who is afraid of flying...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateStory,
                icon: const Icon(Icons.auto_awesome),
                label: const Text("Generate Story"),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : _story.isEmpty
                      ? const Center(
                    child: Text(
                      "Your story will appear here.",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  )
                      : SingleChildScrollView(
                    child: Text(
                      _story,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}