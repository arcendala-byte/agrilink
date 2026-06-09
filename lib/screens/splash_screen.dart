import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin/admin_dashboard.dart';
import 'consumer/consumer_dashboard.dart';
import 'farmer/farmer_dashboard_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _animationController.forward();
    
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    Widget nextScreen;
    
    try {
      nextScreen = await _resolveInitialScreen();
    } catch (e) {
      print('Error resolving initial screen: $e');
      nextScreen = const HomeScreen();
    }
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  Future<Widget> _resolveInitialScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    
    // If no user is logged in, go to home screen
    if (user == null) {
      return const HomeScreen();
    }
    
    // Check for admin emails first (before Firestore query)
    final adminEmails = ['admin@agrilink.com', 'agrilink.admin@gmail.com'];
    if (adminEmails.contains(user.email)) {
      return const AdminDashboard();
    }
    
    try {
      // Safely get user document
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snapshot = await docRef.get();
      
      if (snapshot.exists && snapshot.data() != null) {
        final userData = snapshot.data()!;
        final userRole = userData['userRole'] as String?;
        
        print('User role: $userRole'); // Debug print
        
        switch (userRole) {
          case 'admin':
            return const AdminDashboard();
          case 'farmer':
            return const FarmerDashboardScreen();
          case 'transporter':
            return const ProfileScreen();
          default:
            return const ConsumerDashboard();
        }
      } else {
        // User document doesn't exist - treat as consumer
        print('User document not found for: ${user.uid}');
        return const ConsumerDashboard();
      }
    } catch (e) {
      print('Error fetching user role: $e');
      // Default to consumer dashboard on error
      return const ConsumerDashboard();
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047), Color(0xFF66BB6A)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.agriculture, size: 60, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'AgriLink',
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Connecting Farmers Directly to Markets',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}