// main.dart and router entry point for Smart Classroom

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/student/student_dashboard.dart';
import 'package:app/utils/app_routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Classroom',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const AuthWrapper(),
      routes: appRoutes,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?> (
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // Here you'd normally check Firestore for user role to route properly
          // For now default to student dashboard for demonstration
          return const StudentDashboard();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
