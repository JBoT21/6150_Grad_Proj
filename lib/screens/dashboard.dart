import 'package:flutter/material.dart';
import 'package:team_3_f25_project/screens/wordlist_selection.dart';
//import 'package:team_3_f25_project/widgets/custom_app_bar.dart';
import 'package:team_3_f25_project/widgets/stat_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/screens/login.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String classCode = "";

  @override
  void initState() {
    super.initState();
    _loadClassCode();
  }

  Future<void> _loadClassCode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      classCode = prefs.getString('classCode') ?? "N/A";
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your Class Code:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              classCode,
              style: TextStyle(fontSize: 28, color: Colors.blue),
            ),
            const SizedBox(height: 30),

            // Your existing dashboard widgets...
          ],
        ),
      ),
    );
  }
}
