import 'package:flutter/material.dart';

AppBar customAppBar({dynamic context, String title = ""}) {
  return AppBar(
    title: Text(title),
    actions: [
      ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
        child: Text("Logout"),
      ),
    ],
  );
}
