import 'package:flutter/material.dart';
import '../services/user_db.dart';
import '../models/user.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'student';
  String? _error;

  void _signup() async {
    final db = DatabaseHelper.instance;
    final existing = await db.getUserByEmail(_emailController.text.trim());
    if (existing != null) {
      setState(() => _error = "Email already registered.");
      return;
    }

    final newUser = AppUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _role,
    );

    await db.insertUser(newUser);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(labelText: "Role"),
              items: const [
                DropdownMenuItem(value: 'student', child: Text("Student")),
                DropdownMenuItem(value: 'teacher', child: Text("Teacher")),
              ],
              onChanged: (value) => setState(() => _role = value!),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signup,
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
