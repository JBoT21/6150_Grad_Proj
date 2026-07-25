import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:team_3_f25_project/models/attempt.dart';
import 'package:team_3_f25_project/services/sync_service.dart';
import '../models/user.dart';
import 'list_service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static SyncService? _syncService;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('readright_user.db');
    return _database!;
  }

  // Add this getter
  Future<SyncService> get syncService async {
    if (_syncService != null) return _syncService!;

    final db = await database;
    _syncService = SyncService(localDb: db);

    return _syncService!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    debugPrint('Database located at: $dbPath');
    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        classCode TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid INTEGER NOT NULL,
        wordText TEXT NOT NULL,
        listId INT NOT NULL,
        score INTEGER NOT NULL,
        feedback TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        durationMs INTEGER,
        recordingPath TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE currentList (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid INTEGER NOT NULL,
        currentListId INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
''');
  }

  // User service

  Future<List<Map<String, Object?>>> resetPassword(String email) async {
    final db = await instance.database;
    return await db.rawQuery("UPDATE users SET password = ? WHERE email = ?", [
      'ssssssss',
      email,
    ]);
  }

  String _authEmailFor(String input, {required String role}) {
    final normalized = input.trim().toLowerCase();
    if (role == 'teacher' || normalized.contains('@')) {
      return normalized;
    }
    return '$normalized@readright.local';
  }

  Future<int> insertUser(AppUser user) async {
    try {
      final authEmail = _authEmailFor(user.email, role: user.role);
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: authEmail,
        password: user.password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        return -1;
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': user.name,
        'email': user.email.toLowerCase(),
        'role': user.role,
        'classCode': user.classCode,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final db = await instance.database;
      final localId = await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return localId;
    } catch (e) {
      debugPrint('Failed to create Firebase user: $e');
      return -1;
    }
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final normalizedEmail = email.toLowerCase();
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [normalizedEmail],
    );

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        final firestoreUser = AppUser(
          id: result.isNotEmpty ? result.first['id'] as int? : null,
          name: data['name']?.toString() ?? '',
          email: data['email']?.toString() ?? normalizedEmail,
          password: '',
          role: data['role']?.toString() ?? 'student',
          classCode: data['classCode']?.toString() ?? '',
        );

        return firestoreUser;
      }
    } catch (e) {
      debugPrint('Failed to fetch Firestore user: $e');
    }

    if (result.isNotEmpty) {
      return AppUser.fromMap(result.first);
    }

    return null;
  }

  Future<int> updatePassword(String email, String newPassword) async {
    final db = await instance.database;
    final result = await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
    return result;
  }

  Future<AppUser?> login(String email, String password) async {
    try {
      final authEmail = _authEmailFor(email, role: 'student');
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: authEmail,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        return null;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final data = snapshot.data();
      final role = data?['role']?.toString() ?? 'student';
      final classCode = data?['classCode']?.toString() ?? '';
      final name = data?['name']?.toString() ?? email.split('@').first;

      final existing = await getUserByEmail(email);
      final localId = existing?.id ?? await _upsertLocalUser(
        AppUser(
          name: name,
          email: email.toLowerCase(),
          password: password,
          role: role,
          classCode: classCode,
        ),
      );

      return AppUser(
        id: localId,
        name: name,
        email: email.toLowerCase(),
        password: password,
        role: role,
        classCode: classCode,
      );
    } catch (e) {
      debugPrint('Firebase login failed: $e');
      return null;
    }
  }

  Future<int> _upsertLocalUser(AppUser user) async {
    final db = await instance.database;
    final existing = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [user.email.toLowerCase()],
    );

    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      return id;
    }

    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> addUserListId(int uid, int listId) async {
    final db = await instance.database;
    return await db.insert('currentList', {
      "uid": uid,
      "currentListId": listId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateUserListId(int uid, int nextListId) async {
    debugPrint("Updating list for $uid to list number $nextListId");
    final db = await instance.database;

    final result = await db.rawUpdate(
      'UPDATE currentList SET currentListId = ? WHERE uid = ?',
      [nextListId, uid],
    );
    debugPrint("Update complete: $result");
    return result;
  }

  Future<int?> getUserListId(int uid) async {
    debugPrint("Getting list id for user $uid");
    final db = await instance.database;
    final result = await db.query(
      'currentList',
      columns: ['currentListId'],
      where: 'uid = ?',
      whereArgs: [uid],
    );
    if (result.isNotEmpty) {
      final listId = result[0]['currentListId'];
      debugPrint("List ID: $listId");
      return listId as int;
    }
    return null;
  }

  //Clear all rows in user
  Future<void> clearAllTables() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('users');
    debugPrint('All users deleted from database!');
  }

  //Check for classcode when signing up
  Future<bool> classCodeExists(String classCode) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'role = ? AND classCode = ?',
      whereArgs: ['teacher', classCode],
    );
    return result.isNotEmpty;
  }

  //Get students by classCode for teacher in dashboard screen
  Future<List<AppUser>> getStudentsByClassCode(String classCode) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'role = ? AND classCode = ?',
      whereArgs: ['student', classCode],
    );

    return result.map((row) => AppUser.fromMap(row)).toList();
  }

  Future<double> getStudentProgress(int uid, int currentListId) async {
    final db = await instance.database;

    final allWordsInList = await WordService.getWords(currentListId);

    final listLength = allWordsInList.length;

    if (listLength == 0) return 0.0;

    final attempts = await db.query(
      'attempts',
      where: 'uid = ? AND score = 1 AND listId = ?',
      whereArgs: [uid, currentListId],
    );

    final mastered = attempts.map((a) => a['wordText'] as String).toSet();

    return mastered.length / listLength;
  }

  // missed words by student
  Future<List<Map<String, dynamic>>> getMissedWordsByStudent(
    String email,
  ) async {
    final AppUser? user = await getUserByEmail(email);
    if (user == null) {
      return [];
    }

    final db = await database;
    final result = await db.rawQuery(
      '''
    SELECT 
      wordText, 
      COUNT(*) as attempts, 
      MAX(recordingPath) as lastRecording
    FROM attempts
    WHERE uid = ? AND score = 0
    GROUP BY wordText
    ORDER BY attempts DESC
  ''',
      [user.id],
    );

    return result;
  }

  // Missed words by class
  Future<List<Map<String, dynamic>>> getClassMissedWords(
    String classCode,
  ) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT 
      a.wordText, 
      COUNT(*) as attempts
    FROM attempts a
    JOIN users u ON u.id = a.uid
    WHERE u.classCode = ? AND a.score = 0
    GROUP BY a.wordText
    ORDER BY attempts DESC
  ''',
      [classCode],
    );

    return result;
  }

  Future<AppUser> getUser(int uid) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [uid]);
    return AppUser.fromMap(result.first);
  }

  // Attempts service
  Future<int> insertAttempt(Attempt attempt) async {
    final db = await instance.database;
    return await db.insert('attempts', attempt.toMap());
  }

  Future<Set<String>> getAllCorrectWords(int uid) async {
    final db = await instance.database;
    final allAttempts = await db.query('attempts');

    final correctWords = allAttempts
        .where((a) => a['score'] == 1 && a['uid'] == uid)
        .map((a) => a['wordText'] as String)
        .toSet();
    return correctWords;
  }

  Future<String?> getMostMissedWord(int uid) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT 
      wordText, 
      COUNT(*) as attempts
    FROM attempts
    WHERE uid = ? AND score = 0
    GROUP BY wordText
    ORDER BY attempts DESC
    LIMIT 1
    ''',
      [uid],
    );

    if (result.isEmpty) return "No Words Missed";
    return result.first['wordText'] as String?;
  }
}
