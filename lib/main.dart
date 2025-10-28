import 'package:flutter/material.dart';
import 'package:team_3_f25_project/screens/login.dart';
import 'package:team_3_f25_project/screens/dashboard.dart';
import 'package:team_3_f25_project/screens/wordlist_screen.dart';
import 'package:team_3_f25_project/screens/wordlist_selection.dart';
import 'package:team_3_f25_project/screens/progress.dart';
import 'package:team_3_f25_project/screens/practice.dart';
import 'package:team_3_f25_project/screens/word_practice_page.dart';
import 'package:team_3_f25_project/screens/feedback.dart';

// teacher -> dashboard
// student -> wordlist_selector -> wordlistScreen -> practice -> feedback
//                                      |                ^    |
//                                      |                |     --> practice word
//                                       --> progress ->
void main() {
  Map<String, WidgetBuilder> routes = {
    '/': (context) => ReadRightApp(),
    '/dashboard': (context) => DashboardScreen(),
    '/wordlist_selection': (context) => WordlistSelectionScreen(),
    '/wordlist_screen': (context) => WordlistScreen(),
    '/progress': (context) => ProgressScreen(),
    '/practice': (context) => PracticeScreen(),
    '/practice_word': (context) => WordPracticeScreen(),
    '/feedback': (context) => FeedbackScreen(),
  };
  runApp(MaterialApp(routes: routes));
}

class ReadRightApp extends StatelessWidget {
  const ReadRightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: Login());
  }
}
