// Test harness that fakes out every native plugin WordPracticeScreen
// touches (mic recording, speech recognition, permissions, on-disk paths)
// so the real screen and its real logic can run under `flutter test`
// without a device, while still letting a test pretend a word was heard.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:record_platform_interface/record_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:team_3_f25_project/services/user_db.dart';

const _speechChannel = MethodChannel('plugin.csdcorp.com/speech_to_text');
const _ttsChannel = MethodChannel('flutter_tts');

/// DatabaseHelper does real cross-isolate I/O via sqflite_common_ffi, which
/// tester.pump()/pumpAndSettle() won't wait for even inside runAsync (they
/// advance the frame scheduler, not real wall-clock time). Call this
/// (from inside tester.runAsync) instead, after any action that triggers a
/// DB read behind the widget tree, e.g. after pumpWidget or after
/// simulateSpeechResult.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 50),
  int maxTries = 40,
}) async {
  for (var i = 0; i < maxTries; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await Future.delayed(step);
    await tester.pump();
  }
}

/// One-time process-wide setup: swaps every plugin platform-interface
/// singleton for a fake, and points sqflite at the ffi implementation so
/// DatabaseHelper works on the desktop test runner.
void setUpWordPracticeTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  PathProviderPlatform.instance = _FakePathProviderPlatform();
  PermissionHandlerPlatform.instance = _FakePermissionHandlerPlatform();
  RecordPlatform.instance = _FakeRecordPlatform();

  // InstantFeedback speaks the word via flutter_tts on navigation; give it
  // a no-op platform so that doesn't throw MissingPluginException mid-test.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_ttsChannel, (call) async {
    switch (call.method) {
      case 'speak':
        return 1;
      default:
        return 1;
    }
  });
}

/// Clears the local tables and seeds a single practicing user with
/// [listId] as their current list, so _loadUserAndWords has something
/// consistent to read on every test.
Future<void> resetWordPracticeDatabase({
  required int uid,
  required int listId,
}) async {
  final db = await DatabaseHelper.instance.database;
  await db.delete('attempts');
  await db.delete('currentList');
  await db.delete('users');
  await db.insert('currentList', {'uid': uid, 'currentListId': listId});

  SharedPreferences.setMockInitialValues({'userId': uid});
}

/// Responds to the app's calls *to* speech_to_text (has_permission,
/// initialize, listen, stop, cancel) with canned success responses.
void mockSpeechToTextChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_speechChannel, (call) async {
    switch (call.method) {
      case 'has_permission':
      case 'initialize':
      case 'listen':
      case 'stop':
      case 'cancel':
        return true;
      case 'locales':
        return <String>[];
      default:
        return null;
    }
  });
}

/// Simulates the platform side telling speech_to_text a recognition
/// result came in, as if the user had actually spoken [recognizedWords].
/// This is the seam that stands in for "reading audio": everything
/// upstream of this call (the mic, the OS speech engine) is untestable
/// here, but everything downstream (WordPracticeScreen's own logic) is
/// exercised for real.
Future<void> simulateSpeechResult(
  String recognizedWords, {
  bool finalResult = true,
}) async {
  final payload = jsonEncode({
    'alternates': [
      {'recognizedWords': recognizedWords, 'confidence': 0.9},
    ],
    'finalResult': finalResult,
  });
  final call = MethodCall('textRecognition', payload);
  final data = const StandardMethodCodec().encodeMethodCall(call);
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(_speechChannel.name, data, (_) {});
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.createTempSync('readright_test').path;
  }
}

class _FakePermissionHandlerPlatform extends PermissionHandlerPlatform {
  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return PermissionStatus.granted;
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    return {for (final p in permissions) p: PermissionStatus.granted};
  }
}

class _FakeRecordPlatform extends RecordPlatform {
  @override
  Future<void> create(String recorderId) async {}

  @override
  Future<void> start(
    String recorderId,
    RecordConfig config, {
    required String path,
  }) async {}

  @override
  Future<Stream<Uint8List>> startStream(
    String recorderId,
    RecordConfig config,
  ) async {
    return const Stream.empty();
  }

  @override
  Future<String?> stop(String recorderId) async => null;

  @override
  Future<void> pause(String recorderId) async {}

  @override
  Future<void> resume(String recorderId) async {}

  @override
  Future<bool> isRecording(String recorderId) async => false;

  @override
  Future<bool> isPaused(String recorderId) async => false;

  @override
  Future<bool> hasPermission(String recorderId, {bool request = true}) async {
    return true;
  }

  @override
  Future<void> dispose(String recorderId) async {}

  @override
  Future<Amplitude> getAmplitude(String recorderId) async {
    return Amplitude(current: -160, max: -160);
  }

  @override
  Future<bool> isEncoderSupported(
    String recorderId,
    AudioEncoder encoder,
  ) async {
    return true;
  }

  @override
  Future<List<InputDevice>> listInputDevices(String recorderId) async {
    return const [];
  }

  @override
  Future<void> cancel(String recorderId) async {}

  @override
  Stream<RecordState> onStateChanged(String recorderId) {
    return const Stream.empty();
  }
}
