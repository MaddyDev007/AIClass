import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewResultsScreen extends StatefulWidget {
  const ViewResultsScreen({super.key});

  @override
  State<ViewResultsScreen> createState() => _ViewResultsScreenState();
}

class _ViewResultsScreenState extends State<ViewResultsScreen> {
  String? selectedQuizId;
  List<QueryDocumentSnapshot> quizDocs = [];

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    final snapshot = await FirebaseFirestore.instance.collection('quizzes').get();
    setState(() {
      quizDocs = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Student Results")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedQuizId,
              hint: const Text("Select Quiz"),
              items: quizDocs
                  .map((doc) => DropdownMenuItem(
                        value: doc.id,
                        child: Text("${doc['subject']} - ${doc['class']}"),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedQuizId = val),
            ),
            const SizedBox(height: 20),
            if (selectedQuizId != null)
              Expanded(child: _buildResultsList(selectedQuizId!))
            else
              const Text("Select a quiz to view results."),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(String quizId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('results')
          .doc(quizId)
          .collection('students')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data?.docs ?? [];

        if (results.isEmpty) {
          return const Center(child: Text("No student results available."));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final data = results[index].data() as Map<String, dynamic>;

            return ListTile(
              leading: CircleAvatar(child: Text(data['score'].toString())),
              title: Text("Student ID: ${results[index].id}"),
              subtitle: Text("Correct: ${data['correct']}, Total: ${data['total']}"),
            );
          },
        );
      },
    );
  }
}
