import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageQuizScreen extends StatelessWidget {
  const ManageQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Quizzes")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No quizzes available."));
          }

          final quizzes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              final data = quiz.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['subject'] ?? 'Unknown Subject'),
                  subtitle: Text("Dept: ${data['department']}, Class: ${data['class']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteQuiz(quiz.id, context),
                  ),
                  onTap: () => _viewQuizDetails(context, data),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteQuiz(String id, BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this quiz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm) {
      await FirebaseFirestore.instance.collection('quizzes').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quiz deleted")));
    }
  }

  void _viewQuizDetails(BuildContext context, Map<String, dynamic> data) {
    final questions = data['questions'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Questions"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: questions.length,
            itemBuilder: (_, index) {
              final q = questions[index];
              return ListTile(
                title: Text("Q${index + 1}: ${q['question']}"),
                subtitle: Text("Options: ${q['options'].join(', ')}\nAnswer: ${q['answer']}"),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }
}
