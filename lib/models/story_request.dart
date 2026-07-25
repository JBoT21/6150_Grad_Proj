import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String baseUrl =
      "http://YOUR_SERVER_IP:3000"; // or localhost during development

  static Future<String> generateStory(String prompt) async {
    final response = await http.post(
      Uri.parse("$baseUrl/generateStory"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "prompt": prompt,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final json = jsonDecode(response.body);

    return json["story"];
  }
}