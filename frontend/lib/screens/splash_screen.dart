import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'admin_dashboard.dart';
import 'sweeper_dashboard.dart';
import 'invigilator_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    
    _animationController.forward();
    _checkSavedLogin();
  }

  Future<void> _checkSavedLogin() async {
    // Keep the splash screen visible for at least 2 seconds for a premium feel
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final String? savedRole = prefs.getString('userRole');
    final String? savedName = prefs.getString('userName');

    if (!mounted) return;

    // Route based on saved session
    if (savedRole == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
    } else if (savedRole == 'incharge' && savedName != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => InvigilatorDashboard(facultyName: savedName)));
    } else if (savedRole == 'sweeper' && savedName != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SweeperDashboard(sweeperName: savedName)));
    } else {
      // No saved login, go to the login screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)]),
                  boxShadow: [BoxShadow(color: const Color(0xFF3949AB).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.cleaning_services_rounded, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('Campus Cleaning', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              const Text('Management System', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
              const SizedBox(height: 40),
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFF3949AB), strokeWidth: 3)),
            ],
          ),
        ),
      ),
    );
  }
}