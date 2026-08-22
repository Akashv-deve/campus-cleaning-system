import 'package:flutter/material.dart';
import 'sweeper_dashboard.dart';
import 'invigilator_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  
  // Controls which role tab is currently active
  String _selectedRole = 'sweeper'; // 'sweeper', 'incharge', 'admin'

  void _handleLogin() async {
    FocusScope.of(context).unfocus();
    
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Admin doesn't need to type a username, we assume it's 'admin'
    if (_selectedRole != 'admin' && username.isEmpty) {
      _showError('Please enter your name.');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000)); 
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    // Save to local storage for persistent login!
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', _selectedRole);
    await prefs.setString('userName', username);

    if (!mounted) return;

    // EXPLICIT ROLE ROUTING
    if (_selectedRole == 'admin') {
      if (password == 'admin123') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        _showError('Incorrect Admin password.');
      }
    } 
    else if (_selectedRole == 'incharge') {
      if (password == '1234') {
        // Sends the exact raw name they type to the database filter
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => InvigilatorDashboard(facultyName: username))
        );
      } else {
        _showError('Incorrect Incharge PIN. Try 1234');
      }
    } 
    else if (_selectedRole == 'sweeper') {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => SweeperDashboard(sweeperName: username))
      );
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

  Widget _buildRoleTab(String title, String roleValue) {
    final isSelected = _selectedRole == roleValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = roleValue;
            _usernameController.clear();
            _passwordController.clear();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3949AB) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
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
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)]),
                    boxShadow: [BoxShadow(color: const Color(0xFF3949AB).withValues(alpha:0.3), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: const Icon(Icons.cleaning_services_rounded, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 32),
                
                const Text('Campus Cleaning', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text('Select your role to sign in', style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      // THE 3 BUTTON TOGGLE
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: const Color(0xFFF4F6F8), borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            _buildRoleTab('Sweeper', 'sweeper'),
                            _buildRoleTab('Incharge', 'incharge'),
                            _buildRoleTab('Admin', 'admin'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // DYNAMIC FIELDS BASED ON ROLE
                      if (_selectedRole != 'admin') ...[
                        _buildTextField(
                          controller: _usernameController,
                          label: _selectedRole == 'sweeper' ? 'Sweeper Name' : 'Incharge Name',
                          icon: Icons.person_outline_rounded,
                          isObscure: false,
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      if (_selectedRole != 'sweeper') ...[
                        _buildTextField(
                          controller: _passwordController,
                          label: _selectedRole == 'admin' ? 'Admin Password' : '4-Digit PIN',
                          icon: Icons.lock_outline_rounded,
                          isObscure: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey.shade500),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        const SizedBox(height: 8),
                      ],

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(colors: _isLoading ? [Colors.grey.shade400, Colors.grey.shade500] : [const Color(0xFF3949AB), const Color(0xFF5C6BC0)]),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, required bool isObscure, Widget? suffixIcon}) {
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