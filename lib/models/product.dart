import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String price;
  final String unit;
  final String farmerName;
  final String? farmerId;
  final double rating;
  final int stock;
  final bool isOrganic;
  final String category;
  final List<String> imageUrls;
  final String? thumbnailUrl;
  final String description;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.farmerName,
    this.farmerId,
    required this.rating,
    required this.stock,
    this.isOrganic = false,
    required this.category,
    this.imageUrls = const [],
    this.thumbnailUrl,
    this.description = '',
    required this.createdAt,
  });

  String get displayPrice => 'KSh $price/$unit';
  String get stockStatus => stock > 0 ? 'In Stock' : 'Out of Stock';
  Color get stockColor => stock > 0 ? Colors.green : Colors.red;

  static List<Product> getSampleProducts() {
    return [
      Product(
        id: '1',
        name: 'Fresh Tomatoes',
        price: '50',
        unit: 'kg',
        farmerName: 'Green Acres Farm',
        rating: 4.8,
        stock: 120,
        isOrganic: true,
        category: 'Vegetables',
        description: 'Fresh organic tomatoes grown without pesticides. Perfect for salads and cooking.',
        createdAt: DateTime.now(),
      ),
      Product(
        id: '2',
        name: 'Sweet Bananas',
        price: '30',
        unit: 'dozen',
        farmerName: 'Tropical Fruits Co.',
        rating: 4.9,
        stock: 200,
        isOrganic: false,
        category: 'Fruits',
        description: 'Sweet and ripe bananas, freshly harvested.',
        createdAt: DateTime.now(),
      ),
      Product(
        id: '3',
        name: 'Organic Maize',
        price: '80',
        unit: 'kg',
        farmerName: 'Golden Grain Farm',
        rating: 4.7,
        stock: 500,
        isOrganic: true,
        category: 'Cereals',
        description: 'Premium organic maize, non-GMO.',
        createdAt: DateTime.now(),
      ),
      Product(
        id: '4',
        name: 'Free-range Eggs',
        price: '15',
        unit: 'piece',
        farmerName: 'Happy Hens Farm',
        rating: 4.9,
        stock: 300,
        isOrganic: true,
        category: 'Poultry',
        description: 'Free-range eggs from happy hens.',
        createdAt: DateTime.now(),
      ),
    ];
  }
}
