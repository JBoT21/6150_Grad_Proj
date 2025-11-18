import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/screens/login.dart';
import 'package:team_3_f25_project/screens/dashboard.dart';
import 'package:team_3_f25_project/screens/wordlist_screen.dart';
import 'package:team_3_f25_project/screens/word_practice_page.dart';
import 'package:team_3_f25_project/screens/signup.dart';
import 'package:team_3_f25_project/services/user_db.dart';
import 'services/attempts_repository.dart';
import 'models/progress_view_model.dart';

void main() {
  final attemptsRepo = AttemptsRepository();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProgressViewModel(attemptsRepo)..load(),
      child: const ReadRightApp(),
    ),
  );
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
      int? currentListId = prefs.getInt('currentListId');
      if (currentListId == null) {
        prefs.setInt('currentListId', 1);
        currentListId = 1;
      }
      if (savedEmail != null) {
        final user = await DatabaseHelper.instance.getUserByEmail(savedEmail);
        if (user != null) {
          setState(
            () => _home = user.role == 'teacher'
                ? const DashboardScreen()
                : ProgressScreen(listId: currentListId!),
          );
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
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: false),
      home: _home,
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/wordlist_screen': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ProgressScreen(listId: args['listId'] ?? 1);
        },
        '/practice': (context) => WordPracticeScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
