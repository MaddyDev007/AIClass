import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String? selectedQuizId;
  Map<String, dynamic>? selectedQuiz;
  final Map<int, int> answers = {}; // question index → selected option index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Take a Quiz")),
      body: selectedQuiz == null ? _buildQuizList() : _buildQuizAttempt(),
    );
  }

  Widget _buildQuizList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No quizzes available"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final quiz = docs[index];
            final data = quiz.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(data['subject']),
                subtitle: Text("Dept: ${data['department']} | Class: ${data['class']}"),
                onTap: () {
                  setState(() {
                    selectedQuizId = quiz.id;
                    selectedQuiz = data;
                    answers.clear();
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuizAttempt() {
    final questions = selectedQuiz!['questions'] as List<dynamic>;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Q${index + 1}. ${question['question']}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...List.generate(question['options'].length, (i) {
                    return RadioListTile(
                      title: Text(question['options'][i]),
                      value: i,
                      groupValue: answers[index],
                      onChanged: (val) {
                        setState(() {
                          answers[index] = val!;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          );
        }),
        ElevatedButton(
          onPressed: _submitQuiz,
          child: const Text("Submit Quiz"),
        )
      ],
    );
  }

  Future<void> _submitQuiz() async {
    final questions = selectedQuiz!['questions'] as List<dynamic>;
    int correct = 0;

    for (int i = 0; i < questions.length; i++) {
      final selected = answers[i];
      if (selected != null && questions[i]['options'][selected] == questions[i]['answer']) {
        correct++;
      }
    }

    final total = questions.length;
    final user = FirebaseAuth.instance.currentUser;
    final quizId = selectedQuizId!;
    final scoreData = {
      'score': correct,
      'correct': correct,
      'total': total,
      'submittedAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('results')
        .doc(quizId)
        .collection('students')
        .doc(user!.uid)
        .set(scoreData);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Result"),
        content: Text("You scored $correct out of $total"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                selectedQuiz = null;
                selectedQuizId = null;
                answers.clear();
              });
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}
