import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  static const String apiKey = 'your_api_key'; // Replace with your ChatGPT API key
  static const String endpoint = 'https://api.openai.com/v1/engines/davinci-codex/completions';

  void _sendMessage(String message) async {
    // Add user message to the chat interface
    setState(() {
      _messages.add({
        'message': message,
        'type': 'user',
      });
    });

    // Clear the text field after sending the message
    _messageController.clear();

    // Fetch response from ChatGPT API
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'prompt': message,
        'max_tokens': 50, // Adjust max_tokens as needed for response length
      }),
    );

    if (response.statusCode == 200) {
      // Add ChatGPT's response to the chat interface
      setState(() {
        _messages.add({
          'message': jsonDecode(response.body)['choices'][0]['text'].trim(),
          'type': 'bot',
        });
      });
    } else {
      // Handle errors or display a fallback message
      print('Failed to fetch response: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Start list from bottom
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message['message']),
                  subtitle: Text(message['type'] == 'user' ? 'You' : 'Bot'),
                  tileColor: message['type'] == 'user' ? Colors.blue[100] : Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _sendMessage(value),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ChatbotPage(),
  ));
}
