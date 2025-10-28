import 'package:flutter/material.dart';

import 'screens/student_dashboard.dart';
import 'screens/wordlist_screen.dart';
import 'screens/practice.dart';
import 'screens/feedback.dart';
import 'screens/progress.dart';
import 'screens/teacher_dashboard.dart';

class ReadRightApp extends StatelessWidget {
  const ReadRightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadRight',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/student', // you can change this to '/teacher' for screenshots
      routes: {
        '/student': (context) => const StudentDashboardScreen(),
        '/wordlist': (context) => const WordListScreen(),
        '/practice': (context) => const PracticeScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/teacher': (context) => const TeacherDashboardScreen(),
      },
    );
  }
}
