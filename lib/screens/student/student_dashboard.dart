import 'package:flutter/material.dart';
import 'material_view_screen.dart';
import 'quiz_screen.dart';
import 'chatbot_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DashboardTile(
            title: "📚 View Materials",
            subtitle: "View notes, 2marks, 16marks",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MaterialViewScreen()),
            ),
          ),
          DashboardTile(
            title: "📝 Take Quiz",
            subtitle: "Based on uploaded materials",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuizScreen()),
            ),
          ),
          DashboardTile(
            title: "💬 Chatbot",
            subtitle: "Ask subject-related questions",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DashboardTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
