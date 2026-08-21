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
  bool _isPasswordVisible = false; // NEW: Tracks password visibility

  void _handleLogin() async {
    FocusScope.of(context).unfocus();
    
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty) {
      _showError('Please enter a username.');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000)); 
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    // SMART MVP ROUTING: Determines role based on the password used!
    
    // 1. Admin Login
    if (username.toLowerCase() == 'admin') {
      if (password == 'admin123') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        _showError('Incorrect Admin password.');
      }
    } 
    // 2. Faculty Login (If they use the 1234 PIN, they are faculty!)
    else if (password == '1234') {
      // Strip out "prof" from the login name so the database filter matches the raw name perfectly
      String cleanName = username.toLowerCase()
          .replaceAll('prof.', '')
          .replaceAll('prof', '')
          .trim();
          
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => InvigilatorDashboard(facultyName: cleanName))
      );
    }
    // 3. Sweeper Login (If the password is blank, they are a sweeper!)
    else if (password.isEmpty) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => SweeperDashboard(sweeperName: username))
      );
    } 
    // 4. Invalid Password
    else {
      _showError('Invalid password. Use 1234 for Faculty, or leave blank for Sweeper.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFC62828),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
                
                const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text('Sign in to manage campus duties', style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        icon: Icons.person_outline_rounded,
                        isObscure: false,
                      ),
                      const SizedBox(height: 16),
                      
                      // PASSWORD FIELD WITH EYE ICON
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password (Leave blank for Sweeper)',
                        icon: Icons.lock_outline_rounded,
                        isObscure: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                            color: Colors.grey.shade500,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: _isLoading ? [Colors.grey.shade400, Colors.grey.shade500] : [const Color(0xFF3949AB), const Color(0xFF5C6BC0)],
                          ),
                          boxShadow: _isLoading ? [] : [BoxShadow(color: const Color(0xFF3949AB).withValues(alpha:0.35), blurRadius: 14, offset: const Offset(0, 6))],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _isLoading ? null : _handleLogin,
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                  : const Text('LOG IN', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Colors.indigo.withValues(alpha:0.05), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    'Demo Logins:\nAdmin: admin / admin123\nFaculty: type your name / 1234\nSweeper: type your name / (no password)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.indigo.shade400, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Updated helper widget to accept the suffixIcon
  Widget _buildTextField({
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    required bool isObscure,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: const Color(0xFF3949AB), size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF7F7FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}