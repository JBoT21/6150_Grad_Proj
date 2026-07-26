import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OpenAIService {
  static String get _baseUrl {
    switch (defaultTargetPlatform) {

      case TargetPlatform.android:
        return 'http://10.0.2.2:3000';

      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      default:
        return 'http://localhost:3000';
    }
  }

  static Future<String> generateStory(String prompt) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/story'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': prompt,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['story'];
    } else {
      throw Exception(
        'Failed to generate story: ${response.body}',
      );
    }
  }
}