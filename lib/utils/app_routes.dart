import 'package:flutter/material.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/student/student_dashboard.dart';
import 'package:app/screens/student/material_view_screen.dart';
import 'package:app/screens/student/quiz_screen.dart';
import 'package:app/screens/student/chatbot_screen.dart';
import 'package:app/screens/teacher/teacher_dashboard.dart';
import 'package:app/screens/teacher/upload_material_screen.dart';
import 'package:app/screens/teacher/manage_quiz_screen.dart';
import 'package:app/screens/teacher/view_results_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (_) => const LoginScreen(),
  '/teacher': (_) => const TeacherDashboard(),
  '/upload_material': (_) => const UploadMaterialScreen(),
  '/manage_quiz': (_) => const ManageQuizScreen(),
  '/view_results': (_) => const ViewResultsScreen(),

  '/student': (_) => const StudentDashboard(),
  '/materials': (_) => const MaterialViewScreen(),
  '/quiz': (_) => const QuizScreen(),
  '/chatbot': (_) => const ChatbotScreen(),
};
