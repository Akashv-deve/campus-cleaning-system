// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/sweeper_dashboard.dart';
import 'screens/invigilator_dashboard.dart';

void main() {
  runApp(const CampusCleaningApp());
}

class CampusCleaningApp extends StatelessWidget {
  const CampusCleaningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Cleaning System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      // Define all your app routes here for clean navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/sweeper': (context) => const SweeperDashboard(),
        '/invigilator': (context) => const InvigilatorDashboard(),
      },
    );
  }
}