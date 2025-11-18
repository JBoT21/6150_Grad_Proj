import 'package:flutter/material.dart';
import 'package:team_3_f25_project/screens/wordlist_selection.dart';
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
  Map<int, double> progressMap = {};
  String searchQuery = "";
  String sortOption = "name_asc";

  @override
  void initState() {
    super.initState();
    _loadClassCode();
  }

  Future<void> _loadProgress() async {
    final db = DatabaseHelper.instance;
    Map<int, double> temp = {};

    for (var s in students) {
      double p = await db.getStudentProgress(s.id!);
      temp[s.id!] = p;
    }

    setState(() {
      progressMap = temp;
    });
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
    _loadProgress();
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

  double calculateAverage() {
    if (progressMap.isEmpty) return 0;

    double total = 0;
    for (var value in progressMap.values) {
      total += value;
    }

    return total / progressMap.length;
  }

  List<AppUser> getFilteredAndSortedStudents() {
    List<AppUser> filtered = students.where((s) {
      return s.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    filtered.sort((a, b) {
      double pA = progressMap[a.id] ?? 0;
      double pB = progressMap[b.id] ?? 0;

      switch (sortOption) {
        case "name_asc":
          return a.name.compareTo(b.name);
        case "name_desc":
          return b.name.compareTo(a.name);
        case "progress_desc":
          return pB.compareTo(pA);
        case "progress_asc":
          return pA.compareTo(pB); //
      }
      return 0;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Welcome to Class-$classCode'),
        centerTitle: true,
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
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, size: 32, color: Colors.blueAccent),

                    const SizedBox(height: 8),

                    const Text(
                      "Class Average",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${(calculateAverage() * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WordlistSelectionScreen(),
                  ),
                ),
                child: const Text("Word Lists"),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Search students...",
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Sort By"),
                  value: sortOption,
                  items: const [
                    DropdownMenuItem(
                      value: "name_asc",
                      child: Text("Name (A → Z)"),
                    ),
                    DropdownMenuItem(
                      value: "name_desc",
                      child: Text("Name (Z → A)"),
                    ),
                    DropdownMenuItem(
                      value: "progress_desc",
                      child: Text("Progress (High → Low)"),
                    ),
                    DropdownMenuItem(
                      value: "progress_asc",
                      child: Text("Progress (Low → High)"),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      sortOption = val!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Students in Class $classCode",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              if (loadingStudents)
                const CircularProgressIndicator()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: getFilteredAndSortedStudents().length,
                  itemBuilder: (context, index) {
                    final student = getFilteredAndSortedStudents()[index];
                    final progress = (progressMap[student.id] ?? 0);

                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(student.name),
                      subtitle: Text(
                        "Progress: ${(progress * 100).toStringAsFixed(0)}%",
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.green,
                        ),
                      ),
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
