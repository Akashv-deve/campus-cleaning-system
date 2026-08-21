// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'sweeper_dashboard.dart';
import 'invigilator_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // MOCK LOGIN LOGIC (Preserved exactly as before)
  void _handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(milliseconds: 1200)); 
    final username = _usernameController.text.trim().toLowerCase();
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    // 1. Admin Login
    if (username == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin');
    } 
    // 2. Sweeper Login (Matches the names in your Admin Assign dialog)
    else if (['kumar', 'rajesh', 'lakshmi', 'meena'].contains(username)) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => SweeperDashboard(sweeperName: username))
      );
    } 
    // 3. Faculty Login (Matches the names in your Faculty Allotment dialog)
    else if (username.contains('prof') || ['suresh', 'anita', 'karthik'].contains(username)) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => InvigilatorDashboard(facultyName: username))
      );
    } 
    // 4. Invalid Login
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Invalid user. Try: admin, kumar, or suresh')),
            ],
          ),
          backgroundColor: const Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium Logo Container
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3949AB).withValues(alpha:0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.cleaning_services_rounded, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 32),
                
                // Welcome Text
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to manage campus duties',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Username Input
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        icon: Icons.person_outline_rounded,
                        isObscure: false,
                      ),
                      const SizedBox(height: 16),
                      
                      // Password Input
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        isObscure: true,
                      ),
                      const SizedBox(height: 28),

                      // Animated Gradient Login Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: _isLoading 
                                ? [Colors.grey.shade400, Colors.grey.shade500]
                                : [const Color(0xFF3949AB), const Color(0xFF5C6BC0)],
                          ),
                          boxShadow: _isLoading ? [] : [
                            BoxShadow(
                              color: const Color(0xFF3949AB).withValues(alpha:0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _isLoading ? null : _handleLogin,
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text(
                                      'LOG IN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                // Helper Text for Pitch/Testing
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha:0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Demo Accounts: admin, faculty, sweeper',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for clean text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: const Color(0xFF3949AB), size: 22),
        filled: true,
        fillColor: const Color(0xFFF7F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}