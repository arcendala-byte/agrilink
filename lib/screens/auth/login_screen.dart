import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../dashboard/role_based_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null && mounted) {
        // Debug prints to check user role
        print('✅ User logged in: ${user.email}');
        print('🆔 User UID: ${user.uid}');
        
        // Fetch user role from Firestore
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        print('📋 User data: ${userDoc.data()}');
        print('👑 User role from Firestore: ${userDoc.data()?['userRole']}');
        
        // If role is not set, set it as consumer
        if (userDoc.data()?['userRole'] == null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'userRole': 'consumer',
          });
          print('📝 Set default role to: consumer');
        }
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleBasedDashboard()),
        );
      } else {
        _showSnackBar('Invalid email or password');
      }
    } catch (e) {
      print('Sign in error: $e');
      _showSnackBar('Sign in failed: $e');
    }

    setState(() => _isLoading = false);
  }

  // Temporary button to fix admin role (remove after testing)
  Future<void> _fixAdminRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email == 'agrilink.admin@gmail.com') {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'userRole': 'admin',
      });
      print('✅ Admin role fixed for: ${user.email}');
      _showSnackBar('Admin role updated! Please sign in again.');
      await FirebaseAuth.instance.signOut();
      setState(() {});
    } else if (user != null && user.email == 'admin@agrilink.com') {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'userRole': 'admin',
      });
      print('✅ Admin role fixed for: ${user.email}');
      _showSnackBar('Admin role updated! Please sign in again.');
      await FirebaseAuth.instance.signOut();
      setState(() {});
    } else {
      _showSnackBar('Please login as admin first to fix role');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    size: 50,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'farmer@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _showSnackBar('Password reset coming soon!');
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('Sign In', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : () {
                  _showSnackBar('Google Sign In coming soon!');
                },
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              
              // Temporary button to fix admin role (remove after testing)
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: OutlinedButton.icon(
                  onPressed: _fixAdminRole,
                  icon: const Icon(Icons.admin_panel_settings, size: 18),
                  label: const Text('Fix Admin Role (Temp)', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
