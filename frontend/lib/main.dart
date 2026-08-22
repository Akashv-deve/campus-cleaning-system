// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/admin_dashboard.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const CampusCleaningApp());
}

class CampusCleaningApp extends StatelessWidget {
  const CampusCleaningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Cleaning System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // 1. APPLY GOOGLE FONTS GLOBALLY
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3949AB), // Deep Indigo
          secondary: Colors.amber,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: const Color(0xFFF4F6F8),
          foregroundColor: Colors.black87,
          elevation: 0,
          // Make AppBar titles use the custom font and make them bold
          titleTextStyle: GoogleFonts.nunito(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        // 2. SMOOTH PAGE TRANSITIONS
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            // This gives a beautiful, soft fade-up effect when changing screens
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      
      // THIS IS THE FIX: Use home instead of initialRoute
      home: const SplashScreen(), 
      
      routes: {
        // We removed the '/' route here, because 'home' handles the startup now!
        '/admin': (context) => const AdminDashboard(),
      },
    );
  }
}