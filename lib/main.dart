import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/screens/login.dart';
import 'package:team_3_f25_project/screens/dashboard.dart';
import 'package:team_3_f25_project/screens/wordlist_selection.dart';
import 'package:team_3_f25_project/screens/wordlist_screen.dart';
import 'package:team_3_f25_project/screens/progress.dart';
import 'package:team_3_f25_project/screens/practice.dart';
import 'package:team_3_f25_project/screens/word_practice_page.dart';
import 'package:team_3_f25_project/screens/feedback.dart';
import 'package:team_3_f25_project/screens/signup.dart';
import 'package:team_3_f25_project/services/user_db.dart';

void main() {
  runApp(const ReadRightApp());
}

class ReadRightApp extends StatefulWidget {
  const ReadRightApp({super.key});

  @override
  State<ReadRightApp> createState() => _ReadRightAppState();
}

class _ReadRightAppState extends State<ReadRightApp> {
  Widget _home = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email');
      if (savedEmail != null) {
        final user = await DatabaseHelper.instance.getUserByEmail(savedEmail);
        if (user != null) {
          setState(() => _home = user.role == 'teacher'
              ? const DashboardScreen()
              : const WordlistSelectionScreen());
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading session: $e');
    }
    setState(() => _home = const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadRight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: _home,
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/wordlist_selection': (context) => const WordlistSelectionScreen(),
        '/wordlist_screen': (context) => const WordlistScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/practice': (context) => const PracticeScreen(),
        '/practice_word': (context) => const WordPracticeScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
