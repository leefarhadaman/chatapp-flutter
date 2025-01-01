import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final RxList<String> messages = <String>[].obs;
  final String apiKey = 'AIzaSyDQCZIusX3G5z3b0X-Xp5NEOo2IzSrOKq4'; // Replace with your API key
  final String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=';

  void sendMessage() async {
    String userMessage = messageController.text.trim();
    if (userMessage.isNotEmpty) {
      messages.add("You: $userMessage");
      messageController.clear();

      try {
        String botResponse = await fetchApiResponse(userMessage);
        messages.add("Bot: $botResponse");
      } catch (e) {
        messages.add("Bot: Sorry, an error occurred.");
      }
    }
  }

  Future<String> fetchApiResponse(String userMessage) async {
    final url = Uri.parse('$apiUrl$apiKey');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "contents": [
          {"parts": [{"text": userMessage}]}
        ]
      }),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Access the correct structure in the response
      final text = data["candidates"]?[0]["content"]["parts"]?[0]["text"]?.trim();

      return text ?? "No response";
    } else {
      throw Exception("Failed to fetch API response");
    }
  }
}
