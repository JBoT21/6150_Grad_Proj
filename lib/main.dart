import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/firebase_options.dart';
import 'package:team_3_f25_project/screens/login.dart';
import 'package:team_3_f25_project/screens/dashboard.dart';
import 'package:team_3_f25_project/screens/progress_screen.dart';
import 'package:team_3_f25_project/screens/word_practice_page.dart';
import 'package:team_3_f25_project/screens/balloon_pop_screen.dart';
import 'package:team_3_f25_project/screens/signup.dart';
import 'package:team_3_f25_project/services/user_db.dart';
import 'package:team_3_f25_project/screens/story_builder_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ReadRightApp());

  // Start sync after UI is visible so app launch does not block.
  _startBackgroundSync();
}

Future<void> _startBackgroundSync() async {
  final sync = await DatabaseHelper.instance.syncService;

  try {
    await sync.fullSync(tableName: 'users', primaryKey: 'id');
  } catch (e) {
    debugPrint('Background sync failed for users: $e');
  }

  try {
    await sync.fullSync(tableName: 'attempts', primaryKey: 'id');
  } catch (e) {
    debugPrint('Background sync failed for attempts: $e');
  }

  try {
    await sync.fullSync(tableName: 'currentList', primaryKey: 'id');
  } catch (e) {
    debugPrint('Background sync failed for currentList: $e');
  }

  Timer.periodic(const Duration(minutes: 1), (timer) {
    sync.fullSync(tableName: 'users', primaryKey: 'id');
    sync.fullSync(tableName: 'attempts', primaryKey: 'id');
    sync.fullSync(tableName: 'currentList', primaryKey: 'id');
  });
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
      final currentUser = FirebaseAuth.instance.currentUser;
      final savedEmail = prefs.getString('email');
      final userId = prefs.getInt('userId');

      if (currentUser != null) {
        final email = currentUser.email ?? savedEmail;
        if (email != null) {
          final user = await DatabaseHelper.instance.getUserByEmail(email);
          if (user != null) {
            final currentListId = userId != null
                ? await db.getUserListId(userId)
                : null;
            setState(
              () => _home = user.role == 'teacher'
                  ? const DashboardScreen()
                  : ProgressScreen(listId: currentListId ?? 1),
            );
            return;
          }
        }
      }

      if (savedEmail != null) {
        final user = await DatabaseHelper.instance.getUserByEmail(savedEmail);
        if (user != null) {
          final currentListId = userId != null
              ? await db.getUserListId(userId)
              : null;
          setState(
            () => _home = user.role == 'teacher'
                ? const DashboardScreen()
                : ProgressScreen(listId: currentListId ?? 1),
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
        '/progress_screen': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ProgressScreen(listId: args['listId'] ?? 1);
        },
        '/practice': (context) => WordPracticeScreen(),
        '/story_builder': (context) => const StoryBuilderScreen(),
        '/balloon_pop': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return BalloonPopScreen(listId: args['listId'] ?? 1);
        },
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
