import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {

  static const String _baseUrl = ""; //Change to URL

  static Future<String> generateStory(String prompt) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/api/story"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "prompt": prompt,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to generate story.");
    }

    final json = jsonDecode(response.body);

    return json["story"];
  }
}