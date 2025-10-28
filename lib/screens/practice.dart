import 'package:flutter/material.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: "Practice"),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/feedback");
              },
              child: Text("Feedback"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/practice_word");
              },
              child: Text("Practice Word"),
            ),
          ],
        ),
      ),
    );
  }
}
