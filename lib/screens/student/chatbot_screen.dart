import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool isLoading = false;

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": userMessage});
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse("http://localhost:8000/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"question": userMessage}),
    );

    if (response.statusCode == 200) {
      final aiReply = jsonDecode(response.body)['answer'];
      setState(() {
        _messages.add({"role": "bot", "text": aiReply});
      });
    } else {
      setState(() {
        _messages.add({"role": "bot", "text": "Error: Could not get response."});
      });
    }

    setState(() {
      isLoading = false;
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subject Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.indigo[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg['text'] ?? ""),
                  ),
                );
              },
            ),
          ),
          if (isLoading) const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask a question...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
