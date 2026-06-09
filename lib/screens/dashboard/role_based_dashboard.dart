import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../farmer/farmer_dashboard_screen.dart';
import '../consumer/consumer_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../profile_screen.dart';
import '../home_screen.dart';

class RoleBasedDashboard extends StatelessWidget {
  const RoleBasedDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const HomeScreen();
    }
    
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const HomeScreen();
        }
        
        if (snapshot.hasError) {
          print('Error loading user data: ${snapshot.error}');
          return const HomeScreen();
        }
        
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const HomeScreen();
        }
        
        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final userRole = userData?['userRole'] as String? ?? 'consumer';
        
        print('User role detected: $userRole');
        print('User email: ${user.email}');
        
        // Check for admin role first
        if (userRole == 'admin' || 
            user.email == 'admin@agrilink.com' || 
            user.email == 'agrilink.admin@gmail.com') {
          return const AdminDashboard();
        }
        
        // Check for farmer role - goes to Farmer Dashboard
        if (userRole == 'farmer') {
          return const FarmerDashboardScreen();
        }
        
        // Check for transporter role
        if (userRole == 'transporter') {
          return const ProfileScreen();
        }
        
        // Default consumer role - goes to Consumer Dashboard
        return const ConsumerDashboard();
      },
    );
  }
}
