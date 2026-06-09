import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/admin/admin_models.dart';
import 'users_management_screen.dart';
import 'products_management_screen.dart';
import 'orders_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AdminStats? _stats;
  bool _isLoading = true;
  String _adminName = '';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAdminData();
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _adminName = doc.data()?['name'] ?? 'Administrator';
          _adminEmail = user.email ?? '';
        });
      }
    }
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final farmers = usersSnapshot.docs.where((doc) => doc.data()['userRole'] == 'farmer').length;
      final consumers = usersSnapshot.docs.where((doc) => doc.data()['userRole'] == 'consumer').length;
      final transporters = usersSnapshot.docs.where((doc) => doc.data()['userRole'] == 'transporter').length;
      
      final productsSnapshot = await FirebaseFirestore.instance.collection('products').get();
      
      final ordersSnapshot = await FirebaseFirestore.instance.collection('orders').get();
      final pending = ordersSnapshot.docs.where((doc) => doc.data()['status'] == 'pending').length;
      final completed = ordersSnapshot.docs.where((doc) => doc.data()['status'] == 'delivered').length;
      final cancelled = ordersSnapshot.docs.where((doc) => doc.data()['status'] == 'cancelled').length;
      
      double revenue = 0;
      for (var doc in ordersSnapshot.docs) {
        if (doc.data()['status'] == 'delivered') {
          revenue += (doc.data()['totalAmount'] as num?)?.toDouble() ?? 0;
        }
      }
      
      setState(() {
        _stats = AdminStats(
          totalUsers: usersSnapshot.docs.length,
          totalFarmers: farmers,
          totalConsumers: consumers,
          totalTransporters: transporters,
          totalProducts: productsSnapshot.docs.length,
          totalOrders: ordersSnapshot.docs.length,
          totalRevenue: revenue,
          pendingOrders: pending,
          completedOrders: completed,
          cancelledOrders: cancelled,
        );
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user?.email != 'admin@agrilink.com' && user?.email != 'agrilink.admin@gmail.com') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Access'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Admin Access Only',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to access this page',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.admin_panel_settings),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Users', icon: Icon(Icons.people)),
            Tab(text: 'Products', icon: Icon(Icons.inventory)),
            Tab(text: 'Orders', icon: Icon(Icons.shopping_bag)),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                const UsersManagementScreen(),
                const ProductsManagementScreen(),
                const OrdersManagementScreen(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.red.shade700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings, size: 35, color: Colors.red),
                ),
                const SizedBox(height: 10),
                Text(
                  _adminName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _adminEmail,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'SUPER ADMIN',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', 0),
          _buildDrawerItem(Icons.people, 'User Management', 1),
          _buildDrawerItem(Icons.inventory, 'Product Management', 2),
          _buildDrawerItem(Icons.shopping_bag, 'Order Management', 3),
          _buildDrawerItem(Icons.settings, 'System Settings', 4),
          const Divider(),
          _buildDrawerItem(Icons.analytics, 'Analytics', 5),
          _buildDrawerItem(Icons.report, 'Reports', 6),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', -1, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.grey.shade700),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : null)),
      selected: _tabController.index == index,
      selectedTileColor: Colors.red.shade50,
      onTap: () {
        if (isLogout) {
          _logout();
        } else if (index < 5) {
          _tabController.animateTo(index);
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title feature coming soon!')),
          );
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                        ),
                        Text(
                          _adminName,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Stats Cards - Fixed overflow
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final stats = [
                  {'title': 'Total Users', 'value': _stats!.totalUsers.toString(), 'icon': Icons.people, 'color': Colors.blue},
                  {'title': 'Total Farmers', 'value': _stats!.totalFarmers.toString(), 'icon': Icons.agriculture, 'color': Colors.green},
                  {'title': 'Total Consumers', 'value': _stats!.totalConsumers.toString(), 'icon': Icons.shopping_cart, 'color': Colors.purple},
                  {'title': 'Total Transporters', 'value': _stats!.totalTransporters.toString(), 'icon': Icons.local_shipping, 'color': Colors.orange},
                  {'title': 'Total Products', 'value': _stats!.totalProducts.toString(), 'icon': Icons.inventory, 'color': Colors.teal},
                  {'title': 'Total Orders', 'value': _stats!.totalOrders.toString(), 'icon': Icons.shopping_bag, 'color': Colors.indigo},
                ];
                final stat = stats[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 26),
                      const SizedBox(height: 6),
                      Text(
                        stat['value'] as String,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: stat['color'] as Color),
                      ),
                      Text(
                        stat['title'] as String,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Revenue Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF5722)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Revenue',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'KSh ${_stats!.totalRevenue.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Order Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Order Statistics',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildOrderStat('Pending', _stats!.pendingOrders, Colors.orange)),
                        Expanded(child: _buildOrderStat('Completed', _stats!.completedOrders, Colors.green)),
                        Expanded(child: _buildOrderStat('Cancelled', _stats!.cancelledOrders, Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _stats!.completedOrders / (_stats!.totalOrders > 0 ? _stats!.totalOrders : 1),
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.green,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStat(String title, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      children: [
        _buildSectionHeader('System Settings'),
        SwitchListTile(
          title: const Text('Maintenance Mode'),
          subtitle: const Text('Put the platform in maintenance mode'),
          value: false,
          onChanged: (value) {},
          secondary: const Icon(Icons.build),
        ),
        SwitchListTile(
          title: const Text('User Registration'),
          subtitle: const Text('Allow new user registrations'),
          value: true,
          onChanged: (value) {},
          secondary: const Icon(Icons.person_add),
        ),
        const Divider(),
        
        _buildSectionHeader('Email Settings'),
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('SMTP Configuration'),
          subtitle: const Text('Configure email server settings'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notification Templates'),
          subtitle: const Text('Edit email and SMS templates'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const Divider(),
        
        _buildSectionHeader('Security'),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Admin Accounts'),
          subtitle: const Text('Manage admin users'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.audiotrack),
          title: const Text('Audit Logs'),
          subtitle: const Text('View system activity logs'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const Divider(),
        
        _buildSectionHeader('Data Management'),
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Backup Database'),
          subtitle: const Text('Create manual database backup'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Restore Data'),
          subtitle: const Text('Restore from backup'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        const Divider(),
        
        _buildSectionHeader('Support'),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Admin Guide'),
          subtitle: const Text('View documentation'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: const Text('Report Issue'),
          subtitle: const Text('Report a system issue'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
