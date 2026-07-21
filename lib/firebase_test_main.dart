import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FirebaseTestApp());
}

class FirebaseTestApp extends StatelessWidget {
  const FirebaseTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase Connection Test')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                      .collection('test')
                      .add({'timestamp': DateTime.now().toIso8601String()});
                debugPrint('✅ Firestore write succeeded');
              } catch (e) {
                debugPrint('❌ Firestore write failed: $e');
              }
            },
            child: const Text('Test Firestore Write'),
          ),
        ),
      ),
    );
  }
}