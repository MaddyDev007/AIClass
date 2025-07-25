import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialViewScreen extends StatelessWidget {
  const MaterialViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Study Materials")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('materials').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No materials uploaded."));
          }

          final materials = snapshot.data!.docs;

          return ListView.builder(
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final doc = materials[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['subject'] ?? 'Unknown Subject'),
                  subtitle: Text("Dept: ${data['department']}, Class: ${data['class']}"),
                  onTap: () => showMaterialDialog(context, data),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void showMaterialDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Material - ${data['subject']}"),
        content: SizedBox(
          height: 250,
          width: double.maxFinite,
          child: ListView(
            children: [
              if (data['text'] != null) ...[
                const Text("📘 Lesson Summary:\n", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(data['text']),
                const SizedBox(height: 10),
              ],
              if (data['2marks'] != null) ...[
                const Text("🧠 2-Marks Questions:\n", style: TextStyle(fontWeight: FontWeight.bold)),
                ...List.generate(data['2marks'].length, (i) => Text("${i + 1}. ${data['2marks'][i]}")),
                const SizedBox(height: 10),
              ],
              if (data['16marks'] != null) ...[
                const Text("📝 16-Marks Questions:\n", style: TextStyle(fontWeight: FontWeight.bold)),
                ...List.generate(data['16marks'].length, (i) => Text("${i + 1}. ${data['16marks'][i]}")),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }
}
