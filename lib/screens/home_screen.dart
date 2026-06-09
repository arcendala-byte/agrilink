import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/ai_assistant/ai_assistant_screen.dart';
import '../screens/market_intelligence/market_intelligence_screen.dart';
import '../screens/farmer/farmer_dashboard_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/auth/login_screen.dart';
import 'marketplace_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeTab(),
      const MarketplaceScreen(),
      const MessagesScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = ref.watch(cartTotalItemsProvider);
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 22,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.store_outlined), label: 'Market'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
      floatingActionButton: totalItems > 0 
          ? FloatingActionButton(
              onPressed: () {
                if (user == null) {
                  _showLoginPrompt();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                }
              },
              backgroundColor: const Color(0xFFFFA726),
              child: Stack(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        totalItems.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
  
  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Login Required'),
        content: const Text('Please login or create an account to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
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
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE1EDE1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF24522D),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  User? get _user => FirebaseAuth.instance.currentUser;
  
  final List<Map<String, dynamic>> _banners = [
    {'title': 'Fresh Harvest', 'subtitle': 'Get 20% off on all farm produce', 'color': const Color(0xFFFF9800), 'icon': Icons.agriculture},
    {'title': 'Tractor Express', 'subtitle': 'Free delivery on orders above KSh 1000', 'color': const Color(0xFFFF5722), 'icon': Icons.local_shipping},
    {'title': 'Organic Farming', 'subtitle': 'Buy certified organic products', 'color': const Color(0xFF2E7D32), 'icon': Icons.eco},
    {'title': 'Farmers Market', 'subtitle': 'Direct from farm to table', 'color': const Color(0xFF795548), 'icon': Icons.store},
  ];
  
  int _currentBanner = 0;
  bool _isLoading = true;
  String? _displayName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startBannerCarousel();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _displayName = user.displayName?.split(' ')[0] ?? 'Farmer';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startBannerCarousel() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _currentBanner = (_currentBanner + 1) % _banners.length;
        });
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final totalItems = ref.watch(cartTotalItemsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;
    final hour = DateTime.now().hour;
    
    String greeting;
    IconData greetingIcon;
    
    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_twilight;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nightlight_round;
    }
    
    final products = [
      {'id': '1', 'name': 'Fresh Tomatoes', 'price': '50', 'unit': '/kg', 'rating': '4.8', 'farmer': 'Green Acres', 'organic': true, 'stock': '120 kg'},
      {'id': '2', 'name': 'Sweet Bananas', 'price': '30', 'unit': '/dozen', 'rating': '4.9', 'farmer': 'Tropical Fruits', 'organic': false, 'stock': '200 dozen'},
      {'id': '3', 'name': 'Organic Maize', 'price': '80', 'unit': '/kg', 'rating': '4.7', 'farmer': 'Golden Grain', 'organic': true, 'stock': '500 kg'},
      {'id': '4', 'name': 'Free-range Eggs', 'price': '15', 'unit': '/piece', 'rating': '4.9', 'farmer': 'Happy Hens', 'organic': true, 'stock': '300 pieces'},
    ];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),
      body: CustomScrollView(
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 154,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1B5E20),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF123F22), Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  ),
                ),
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AgriLink',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(greetingIcon, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      if (_isLoading)
                        Container(
                          width: 80,
                          height: 12,
                          color: Colors.white.withOpacity(0.3),
                        )
                      else
                        Text(
                          user != null ? '$greeting, ${_displayName ?? 'Farmer'}' : '$greeting, welcome',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 15),
              centerTitle: false,
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    tooltip: 'Cart',
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      if (user == null) {
                        _showLoginPrompt();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CartScreen()),
                        );
                      }
                    },
                  ),
                  if (totalItems > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          totalItems.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                tooltip: 'Market intelligence',
                icon: const Icon(Icons.insights_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MarketIntelligenceScreen()),
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(
                    user != null ? Icons.person : Icons.login,
                    size: 18,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                onSelected: (value) async {
                  try {
                    if (value == 'login') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    } else if (value == 'farmer_dashboard') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FarmerDashboardScreen()),
                      );
                    } else if (value == 'wallet') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WalletScreen()),
                      );
                    } else if (value == 'logout') {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out successfully')),
                        );
                        setState(() {
                          _displayName = null;
                        });
                      }
                    } else if (value == 'profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    }
                  } catch (e) {
                    print('Error in popup menu: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                itemBuilder: (context) {
                  if (user == null) {
                    return const [
                      PopupMenuItem(
                        value: 'login',
                        child: Row(
                          children: [
                            Icon(Icons.login, size: 20),
                            SizedBox(width: 12),
                            Text('Login / Sign Up'),
                          ],
                        ),
                      ),
                    ];
                  }
                  return [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 20),
                          SizedBox(width: 12),
                          Text('My Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'farmer_dashboard',
                      child: Row(
                        children: [
                          Icon(Icons.dashboard, size: 20, color: Color(0xFF2E7D32)),
                          SizedBox(width: 12),
                          Text('Farmer Dashboard'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'wallet',
                      child: Row(
                        children: [
                          Icon(Icons.wallet, size: 20, color: Color(0xFFFFA726)),
                          SizedBox(width: 12),
                          Text('My Wallet'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Logout', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ];
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: _buildHeroSection(user),
          ),
          
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search fresh produce...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                    suffixIcon: IconButton(
                      tooltip: 'Filter',
                      icon: const Icon(Icons.tune, color: Color(0xFF2E7D32)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Filters coming soon')),
                        );
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onSubmitted: (query) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Searching for: $query')),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Banner Carousel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  final banner = _banners[_currentBanner];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${banner['title']} promotion!')),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _banners[_currentBanner]['color'] as Color,
                        (_banners[_currentBanner]['color'] as Color).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (_banners[_currentBanner]['color'] as Color).withOpacity(0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(_banners[_currentBanner]['icon'] as IconData, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _banners[_currentBanner]['title'] as String,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _banners[_currentBanner]['subtitle'] as String,
                                style: const TextStyle(color: Colors.white, height: 1.3, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Categories Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shop by Category',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF173B22)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryCard('Vegetables', Icons.eco, const Color(0xFF4CAF50)),
                        _buildCategoryCard('Fruits', Icons.apple, const Color(0xFFFF9800)),
                        _buildCategoryCard('Cereals', Icons.grass, const Color(0xFF795548)),
                        _buildCategoryCard('Dairy', Icons.egg, const Color(0xFF2196F3)),
                        _buildCategoryCard('Poultry', Icons.pets, const Color(0xFFFF5722)),
                        _buildCategoryCard('Organic', Icons.spa, const Color(0xFF8BC34A)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Stats Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(child: _buildStatCard('24', 'Orders', Icons.shopping_cart, Colors.green.shade50)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('KSh 12K', 'Revenue', Icons.attach_money, Colors.orange.shade50)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('8', 'Active', Icons.trending_up, Colors.blue.shade50)),
                ],
              ),
            ),
          ),
          
          // AI Assistant Card
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AIAssistantScreen()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Icon(Icons.assistant, color: Colors.white, size: 45),
                    title: Text('AI Farming Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('Ask me about crop diseases, weather, and prices', style: TextStyle(color: Colors.white70)),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          
          // Featured Products Header
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF173B22)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ),
          
          // Products Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: screenWidth < 380 ? 0.62 : 0.68,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = products[index];
                  return _buildProductCard(
                    product['id'] as String,
                    product['name'] as String,
                    product['price'] as String,
                    product['unit'] as String,
                    product['rating'] as String,
                    product['farmer'] as String,
                    product['organic'] as bool,
                  );
                },
                childCount: products.length,
              ),
            ),
          ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _buildHeroSection(User? user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFEAF6E8)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B5E20).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user == null ? 'Fresh produce, direct from farms' : 'Your farm marketplace is ready',
                      style: const TextStyle(
                        fontSize: 21,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF173B22),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shop, sell, track orders, and monitor market prices from one polished dashboard.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _HeroChip(icon: Icons.verified_outlined, label: 'Verified farms'),
                        _HeroChip(icon: Icons.local_shipping_outlined, label: 'Fast delivery'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.agriculture, color: Colors.white, size: 38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Login Required'),
        content: const Text('Please login or create an account to continue.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    final user = _user;
    return GestureDetector(
      onTap: () {
        if (user == null) {
          _showLoginPrompt();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Viewing $title products')));
        }
      },
      child: Container(
        width: 86,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withOpacity(0.18)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF233528)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF173B22))),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(String id, String name, String price, String unit, String rating, String farmer, bool isOrganic) {
    final user = _user;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productName: name,
              productPrice: price,
              productUnit: unit,
              productRating: rating,
              farmerName: farmer,
            ),
          ),
        );
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(offset: Offset(0, 10 * (1 - value)), child: child),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 104,
                    width: double.infinity,
                    child: Shimmer.fromColors(
                      baseColor: Colors.green.shade100,
                      highlightColor: Colors.white,
                      child: Container(
                        color: Colors.green.shade100,
                        child: const Center(child: Icon(Icons.shopping_bag_outlined, size: 45, color: Colors.green)),
                      ),
                    ),
                  ),
                  if (isOrganic)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(999)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco, size: 10, color: Colors.white),
                            SizedBox(width: 3),
                            Text('Organic', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1D2B20)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 6),
                          Icon(Icons.person_outline, size: 11, color: Colors.grey.shade500),
                          const SizedBox(width: 2),
                          Expanded(child: Text(farmer, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const Spacer(),
                      Text('KSh $price$unit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.green.shade800)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 34,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (user == null) {
                              _showLoginPrompt();
                            } else {
                              try {
                                ref.read(cartProvider.notifier).addItem(CartItem(
                                  id: id, 
                                  name: name, 
                                  price: price, 
                                  unit: unit, 
                                  farmerName: farmer,
                                ));
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Added $name to cart!'), backgroundColor: const Color(0xFF2E7D32), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)),
                                  );
                                }
                              } catch (e) {
                                print('Error adding to cart: $e');
                              }
                            }
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 15),
                          label: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA726),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                          ),
                        ),
                      ),
                    ],
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