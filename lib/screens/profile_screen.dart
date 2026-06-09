import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../screens/verification/farmer_verification_screen.dart';
import '../screens/orders/orders_list_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/saved/saved_products_screen.dart';
import '../screens/payment/payment_methods_screen.dart';
import '../screens/address/delivery_addresses_screen.dart';
import '../screens/offers/offers_deals_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/help/help_center_screen.dart';
import 'auth/login_screen.dart';
import 'dashboard/role_based_dashboard.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Not Logged In',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Please login to view your profile',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }
    
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final userRole = userData?['userRole'] as String? ?? 'consumer';
        final userName = userData?['name'] ?? user.displayName ?? 'User';
        final userEmail = user.email ?? '';
        final userPhone = userData?['phone'] ?? '';
        final isVerified = userData?['isVerified'] ?? false;
        final verificationStatus = userData?['verificationStatus'] ?? 'not_submitted';
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Profile Avatar with Role Badge
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xFF2E7D32),
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(userRole),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          _getRoleIcon(userRole),
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Verification Badge for Farmers
                    if (userRole == 'farmer' && isVerified)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                if (userPhone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    userPhone,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRoleColor(userRole).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getRoleIcon(userRole), size: 16, color: _getRoleColor(userRole)),
                      const SizedBox(width: 4),
                      Text(
                        _getRoleDisplayName(userRole, isVerified),
                        style: TextStyle(color: _getRoleColor(userRole)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Role-Specific Menu
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Dashboard (Role-specific)
                      _buildMenuItem(Icons.dashboard, 'My Dashboard', () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RoleBasedDashboard()),
                        );
                      }),
                      const Divider(height: 1),
                      
                      // My Orders (for all users)
                      _buildMenuItem(Icons.shopping_bag, 'My Orders', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OrdersListScreen()),
                        );
                      }),
                      const Divider(height: 1),
                      
                      // Role-Specific Menu Items
                      if (userRole == 'farmer') ...[
                        // Verification Status for Farmers
                        if (!isVerified)
                          _buildMenuItem(Icons.verified, 'Get Verified', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FarmerVerificationScreen()),
                            );
                          }, subtitle: verificationStatus == 'pending' ? 'Pending Review' : 'Submit Documents'),
                        
                        if (verificationStatus == 'pending')
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.hourglass_empty, size: 16, color: Colors.orange),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Verification in progress. This usually takes 1-2 business days.',
                                    style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        if (isVerified)
                          _buildMenuItem(Icons.verified, 'Verified Badge', () {}, subtitle: 'Your account is verified'),
                        
                        const Divider(height: 1),
                        _buildMenuItem(Icons.add, 'Add Product', () {
                          // Navigate to add product
                        }),
                        const Divider(height: 1),
                        _buildMenuItem(Icons.inventory, 'Manage Products', () {
                          // Navigate to manage products
                        }),
                      ],
                      
                      if (userRole == 'transporter') ...[
                        _buildMenuItem(Icons.local_shipping, 'Available Jobs', () {
                          _showComingSoon(context, 'Available Jobs');
                        }),
                        const Divider(height: 1),
                        _buildMenuItem(Icons.history, 'Delivery History', () {
                          _showComingSoon(context, 'Delivery History');
                        }),
                      ],
                      
                      // Common Features for All Users
                      if (userRole != 'farmer') ...[
                        _buildMenuItem(Icons.favorite, 'Saved Products', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SavedProductsScreen()),
                          );
                        }),
                        const Divider(height: 1),
                      ],
                      
                      _buildMenuItem(Icons.payment, 'Payment Methods', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                        );
                      }),
                      const Divider(height: 1),
                      
                      _buildMenuItem(Icons.location_on, 'Delivery Addresses', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DeliveryAddressesScreen()),
                        );
                      }),
                      const Divider(height: 1),
                      
                      _buildMenuItem(Icons.shopping_cart, 'My Cart', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CartScreen()),
                        );
                      }),
                      const Divider(height: 1),
                      
                      _buildMenuItem(Icons.wallet, 'My Wallet', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WalletScreen()),
                        );
                      }),
                      const Divider(height: 1),
                      
                      _buildMenuItem(Icons.local_offer, 'Offers & Deals', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OffersDealsScreen()),
                        );
                      }),
                      const Divider(height: 1),
                      
                      _buildMenuItem(Icons.settings, 'Settings', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      }),
                      const Divider(height: 1),
                      
                      _buildMenuItem(Icons.help, 'Help Center', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                        );
                      }),
                      const Divider(height: 1),
                      
                      _buildMenuItem(Icons.info, 'About', () {
                        _showAboutDialog(context);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Logout Button
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildMenuItem(Icons.logout, 'Logout', () {
                    _showLogoutDialog(context);
                  }, color: Colors.red),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Color? color, String? subtitle}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey.shade700),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
  
  Color _getRoleColor(String role) {
    switch (role) {
      case 'farmer':
        return const Color(0xFF2E7D32);
      case 'transporter':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
  
  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'farmer':
        return Icons.agriculture;
      case 'transporter':
        return Icons.local_shipping;
      default:
        return Icons.shopping_cart;
    }
  }
  
  String _getRoleDisplayName(String role, bool isVerified) {
    switch (role) {
      case 'farmer':
        return isVerified ? 'Verified Farmer ✓' : 'Farmer';
      case 'transporter':
        return 'Transporter';
      default:
        return 'Consumer';
    }
  }
  
  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About AgriLink'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.agriculture, size: 50, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'AgriLink',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connecting Farmers Directly to Markets',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2024 AgriLink. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
