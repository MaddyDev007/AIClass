import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UploadMaterialScreen extends StatefulWidget {
  const UploadMaterialScreen({super.key});

  @override
  State<UploadMaterialScreen> createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends State<UploadMaterialScreen> {
  String? department;
  String? classYear;
  String? subject;
  File? selectedFile;
  bool isLoading = false;

  final departments = ['CSE', 'ECE', 'EEE'];
  final classes = ['I-year', 'II-year', 'III-year', 'IV-year'];

  void pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> uploadFile() async {
    if (department == null || classYear == null || subject == null || selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    final uri = Uri.parse("http://localhost:8000/upload_material");
    final request = http.MultipartRequest('POST', uri)
      ..fields['department'] = department!
      ..fields['class'] = classYear!
      ..fields['subject'] = subject!
      ..files.add(await http.MultipartFile.fromPath('file', selectedFile!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Material uploaded & quiz generated")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Material")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: department,
              items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              hint: const Text("Select Department"),
              onChanged: (val) => setState(() => department = val),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: classYear,
              items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              hint: const Text("Select Class"),
              onChanged: (val) => setState(() => classYear = val),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: "Subject"),
              onChanged: (val) => subject = val,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: const Icon(Icons.upload_file),
              label: Text(selectedFile == null ? "Pick PDF" : "Change File"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: uploadFile,
                    child: const Text("Upload & Generate Quiz"),
                  ),
          ],
        ),
      ),
    );
  }
}
