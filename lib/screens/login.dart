import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 10.0,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(height: 50.0, child: Text("Login placeholder")),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, "/dashboard");
            },
            child: Text("Teacher login"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, "/wordlist_selection");
            },
            child: Text("Student login"),
          ),
        ],
      ),
    );
  }
}
