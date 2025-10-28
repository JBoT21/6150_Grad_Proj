import 'package:flutter/material.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: "Feedback"),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/wordlist_selection");
              },
              child: Text("Wordlist Selection"),
            ),
          ],
        ),
      ),
    );
  }
}
