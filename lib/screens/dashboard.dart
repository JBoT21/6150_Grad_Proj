import 'package:flutter/material.dart';
import 'package:team_3_f25_project/screens/wordlist_selection.dart';
//import 'package:team_3_f25_project/widgets/custom_app_bar.dart';
import 'package:team_3_f25_project/widgets/stat_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/screens/login.dart';
import '../models/user.dart';
import '../services/user_db.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String classCode = "";
  List<AppUser> students = [];
  bool loadingStudents = true;

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
    _loadStudents(classCode);
  }

  Future<void> _loadStudents(String code) async {
    final db = DatabaseHelper.instance;
    final list = await db.getStudentsByClassCode(code);

    setState(() {
      students = list;
      loadingStudents = false;
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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Welcome to Class-$classCode'),
        backgroundColor: Colors.blueAccent[50],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              StatTile(
                label: "Class Average",
                value: "100",
                icon: Icons.check,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _openWordListSelection(context),
                child: const Text("Word Lists"),
              ),
              const SizedBox(height: 30),
              Text(
                "Students in Class $classCode",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (loadingStudents)
                const CircularProgressIndicator()
              else if (students.isEmpty)
                const Text("No students in this class.")
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(student.name),
                    );
                  },
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
