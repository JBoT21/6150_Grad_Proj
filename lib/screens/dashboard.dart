import 'package:flutter/material.dart';
import 'package:team_3_f25_project/screens/wordlist_selection.dart';
//import 'package:team_3_f25_project/widgets/custom_app_bar.dart';
import 'package:team_3_f25_project/widgets/stat_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/screens/login.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // Temporary navigation to wordlist page feel free to change
  void _openWordListSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WordlistSelectionScreen()),
    );
  }

  // Temporary navigation to wordlist page feel free to change
  void _openWordListSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WordlistSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StatTile(
              label: "Class Average",
              value: "100",
              icon: Icons.check,
            ),
            // Basic button to get to wordlist page feel free to change
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _openWordListSelection(context),
              child: const Text("Word Lists"),
            ),
          ],
        ),
      ),
    );
  }
}
