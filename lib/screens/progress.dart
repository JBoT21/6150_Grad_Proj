import 'package:flutter/material.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context: context, title: "Progress"),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/practice");
              },
              child: Text("Practice"),
            ),
          ],
        ),
      ),
    );
  }
}
