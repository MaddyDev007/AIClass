import 'package:flutter/material.dart';
import 'upload_material_screen.dart';
import 'manage_quiz_screen.dart';
import 'view_results_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Add FirebaseAuth logout logic
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DashboardTile(
            title: "📄 Upload Materials",
            subtitle: "PDF/Text materials",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadMaterialScreen()),
            ),
          ),
          DashboardTile(
            title: "🧠 Manage Quizzes",
            subtitle: "Create & View",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageQuizScreen()),
            ),
          ),
          DashboardTile(
            title: "📊 View Student Results",
            subtitle: "Analyze performance",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ViewResultsScreen()),
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
