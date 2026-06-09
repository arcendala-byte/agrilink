import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../screens/product_detail_screen.dart';
import '../models/filter_options.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  FilterOptions _filterOptions = FilterOptions();
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits', 
    'Cereals',
    'Dairy',
    'Poultry',
    'Organic',
  ];
  
  final List<Map<String, dynamic>> _allProducts = [
    {'id': '1', 'name': 'Fresh Tomatoes', 'price': 50, 'farmer': 'Green Acres', 'farmerId': 'farmer1', 'unit': 'kg', 'rating': 4.8, 'organic': true, 'category': 'Vegetables', 'stock': 120, 'imageUrl': '', 'description': 'Fresh organic tomatoes grown without pesticides.'},
    {'id': '2', 'name': 'Sweet Bananas', 'price': 30, 'farmer': 'Tropical Fruits', 'farmerId': 'farmer2', 'unit': 'dozen', 'rating': 4.9, 'organic': false, 'category': 'Fruits', 'stock': 200, 'imageUrl': '', 'description': 'Sweet and ripe bananas.'},
    {'id': '3', 'name': 'Organic Maize', 'price': 80, 'farmer': 'Golden Grain', 'farmerId': 'farmer3', 'unit': 'kg', 'rating': 4.7, 'organic': true, 'category': 'Cereals', 'stock': 500, 'imageUrl': '', 'description': 'Premium organic maize.'},
    {'id': '4', 'name': 'Free-range Eggs', 'price': 15, 'farmer': 'Happy Hens', 'farmerId': 'farmer4', 'unit': 'piece', 'rating': 4.9, 'organic': true, 'category': 'Poultry', 'stock': 300, 'imageUrl': '', 'description': 'Free-range eggs.'},
    {'id': '5', 'name': 'Red Onions', 'price': 70, 'farmer': 'Valley Farms', 'farmerId': 'farmer5', 'unit': 'kg', 'rating': 4.6, 'organic': false, 'category': 'Vegetables', 'stock': 150, 'imageUrl': '', 'description': 'Fresh red onions.'},
    {'id': '6', 'name': 'Green Peppers', 'price': 90, 'farmer': 'Fresh Harvest', 'farmerId': 'farmer6', 'unit': 'kg', 'rating': 4.8, 'organic': false, 'category': 'Vegetables', 'stock': 80, 'imageUrl': '', 'description': 'Crisp green peppers.'},
    {'id': '7', 'name': 'Irish Potatoes', 'price': 85, 'farmer': 'Highland Farms', 'farmerId': 'farmer7', 'unit': 'kg', 'rating': 4.7, 'organic': false, 'category': 'Vegetables', 'stock': 300, 'imageUrl': '', 'description': 'Premium Irish potatoes.'},
    {'id': '8', 'name': 'Cabbage', 'price': 40, 'farmer': 'Green Valley', 'farmerId': 'farmer8', 'unit': 'piece', 'rating': 4.5, 'organic': false, 'category': 'Vegetables', 'stock': 100, 'imageUrl': '', 'description': 'Fresh cabbage.'},
    {'id': '9', 'name': 'Carrots', 'price': 60, 'farmer': 'Root Farms', 'farmerId': 'farmer9', 'unit': 'kg', 'rating': 4.8, 'organic': true, 'category': 'Vegetables', 'stock': 200, 'imageUrl': '', 'description': 'Sweet organic carrots.'},
    {'id': '10', 'name': 'Spinach', 'price': 45, 'farmer': 'Leafy Greens', 'farmerId': 'farmer10', 'unit': 'bunch', 'rating': 4.9, 'organic': true, 'category': 'Vegetables', 'stock': 90, 'imageUrl': '', 'description': 'Fresh spinach.'},
    {'id': '11', 'name': 'Broccoli', 'price': 120, 'farmer': 'Organic Life', 'farmerId': 'farmer11', 'unit': 'kg', 'rating': 4.9, 'organic': true, 'category': 'Vegetables', 'stock': 60, 'imageUrl': '', 'description': 'Organic broccoli.'},
    {'id': '12', 'name': 'Avocado', 'price': 100, 'farmer': 'Tropical Delight', 'farmerId': 'farmer12', 'unit': 'piece', 'rating': 4.8, 'organic': false, 'category': 'Fruits', 'stock': 250, 'imageUrl': '', 'description': 'Creamy avocados.'},
    {'id': '13', 'name': 'Mangoes', 'price': 80, 'farmer': 'Tropical Delight', 'farmerId': 'farmer12', 'unit': 'kg', 'rating': 4.7, 'organic': false, 'category': 'Fruits', 'stock': 180, 'imageUrl': '', 'description': 'Sweet mangoes.'},
    {'id': '14', 'name': 'Pineapples', 'price': 120, 'farmer': 'Tropical Fruits', 'farmerId': 'farmer2', 'unit': 'piece', 'rating': 4.8, 'organic': false, 'category': 'Fruits', 'stock': 90, 'imageUrl': '', 'description': 'Sweet pineapples.'},
    {'id': '15', 'name': 'Oranges', 'price': 60, 'farmer': 'Citrus Farms', 'farmerId': 'farmer13', 'unit': 'kg', 'rating': 4.6, 'organic': true, 'category': 'Fruits', 'stock': 220, 'imageUrl': '', 'description': 'Fresh oranges.'},
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    var products = List<Map<String, dynamic>>.from(_allProducts);
    
    if (_filterOptions.category != null && _filterOptions.category != 'All') {
      products = products.where((p) => p['category'] == _filterOptions.category).toList();
    }
    
    if (_filterOptions.organicOnly == true) {
      products = products.where((p) => p['organic'] == true).toList();
    }
    
    if (_filterOptions.minPrice != null) {
      products = products.where((p) => (p['price'] as int) >= _filterOptions.minPrice!).toList();
    }
    if (_filterOptions.maxPrice != null) {
      products = products.where((p) => (p['price'] as int) <= _filterOptions.maxPrice!).toList();
    }
    
    if (_filterOptions.sortBy == 'price_low') {
      products.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    } else if (_filterOptions.sortBy == 'price_high') {
      products.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
    } else if (_filterOptions.sortBy == 'rating') {
      products.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    } else if (_filterOptions.sortBy == 'name') {
      products.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    }
    
    return products;
  }

  void _addToCart(Map<String, dynamic> product) {
    ref.read(cartProvider.notifier).addItem(
      CartItem(
        id: product['id'],
        name: product['name'],
        price: product['price'].toString(),
        unit: product['unit'],
        farmerName: product['farmer'],
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product['name']} to cart!'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;
    final filteredProducts = _filteredProducts;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterSheet(),
              ),
              if (_filterOptions.isActive)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _filterOptions.category == category || 
                                  (category == 'All' && _filterOptions.category == null);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (category == 'All') {
                          _filterOptions.category = null;
                        } else {
                          _filterOptions.category = category;
                        }
                      });
                    },
                    selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF2E7D32),
                  ),
                );
              },
            ),
          ),
          
          if (_filterOptions.isActive)
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_filterOptions.organicOnly == true)
                    _buildActiveFilterChip('Organic', () {
                      setState(() => _filterOptions.organicOnly = null);
                    }),
                  if (_filterOptions.minPrice != null || _filterOptions.maxPrice != null)
                    _buildActiveFilterChip(
                      'Price: ${_filterOptions.minPrice?.toInt() ?? 0}-${_filterOptions.maxPrice?.toInt() ?? 999}',
                      () {
                        setState(() {
                          _filterOptions.minPrice = null;
                          _filterOptions.maxPrice = null;
                        });
                      },
                    ),
                  if (_filterOptions.sortBy != null)
                    _buildActiveFilterChip(
                      _getSortLabel(_filterOptions.sortBy!),
                      () {
                        setState(() => _filterOptions.sortBy = null);
                      },
                    ),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: TextButton(
                      onPressed: () {
                        setState(() => _filterOptions.clear());
                      },
                      child: const Text('Clear All', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredProducts.length} products found',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (filteredProducts.isEmpty)
                  const Text('No matches found', style: TextStyle(fontSize: 12, color: Colors.orange)),
              ],
            ),
          ),
          
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No products found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text('Try adjusting your filters', style: TextStyle(color: Colors.grey.shade500)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => setState(() => _filterOptions.clear()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onDelete,
        backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'price_low': return 'Price: Low to High';
      case 'price_high': return 'Price: High to Low';
      case 'rating': return 'Top Rated';
      case 'name': return 'Name A-Z';
      default: return sortBy;
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double minPrice = _filterOptions.minPrice ?? 0;
        double maxPrice = _filterOptions.maxPrice ?? 200;
        
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filters', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    const Text('Product Type', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _filterOptions.organicOnly ?? false,
                          onChanged: (value) {
                            setState(() {
                              _filterOptions.organicOnly = value;
                            });
                          },
                          activeColor: const Color(0xFF2E7D32),
                        ),
                        const Text('Organic Only'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Price Range (KSh)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: RangeValues(minPrice, maxPrice),
                      min: 0,
                      max: 500,
                      divisions: 50,
                      activeColor: const Color(0xFF2E7D32),
                      onChanged: (values) {
                        setState(() {
                          minPrice = values.start;
                          maxPrice = values.end;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Min: KSh ${minPrice.toInt()}'),
                        Text('Max: KSh ${maxPrice.toInt()}'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _filterOptions.minPrice = minPrice > 0 ? minPrice : null;
                                _filterOptions.maxPrice = maxPrice < 500 ? maxPrice : null;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sort By', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSortOption('Recommended', null),
              _buildSortOption('Price: Low to High', 'price_low'),
              _buildSortOption('Price: High to Low', 'price_high'),
              _buildSortOption('Top Rated', 'rating'),
              _buildSortOption('Name A-Z', 'name'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, String? value) {
    final isSelected = _filterOptions.sortBy == value;
    
    return ListTile(
      title: Text(label),
      leading: isSelected ? const Icon(Icons.check, color: Color(0xFF2E7D32)) : null,
      onTap: () {
        setState(() => _filterOptions.sortBy = value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final isLowStock = (product['stock'] as int) < 50;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productName: product['name'],
              productPrice: product['price'].toString(),
              productUnit: product['unit'],
              productRating: product['rating'].toString(),
              farmerName: product['farmer'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: product['imageUrl'] != null && product['imageUrl'].toString().isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product['imageUrl'],
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 100,
                            color: Colors.green.shade100,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 100,
                            color: Colors.green.shade100,
                            child: const Icon(Icons.image_not_supported, size: 30, color: Colors.green),
                          ),
                        )
                      : Container(
                          height: 100,
                          width: double.infinity,
                          color: Colors.green.shade100,
                          child: const Center(
                            child: Icon(Icons.store, size: 45, color: Colors.green),
                          ),
                        ),
                ),
                if (product['organic'] == true)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco, size: 10, color: Colors.white),
                          SizedBox(width: 2),
                          Text('Organic', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                if (isLowStock)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Low Stock',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 10, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(product['rating'].toString(), style: const TextStyle(fontSize: 10)),
                      const SizedBox(width: 6),
                      Icon(Icons.person, size: 9, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          product['farmer'],
                          style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KSh ${product['price']}/${product['unit']}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFA726),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_shopping_cart, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Add', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
