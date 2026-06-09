import 'package:flutter/material.dart';

class FarmerProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final int quantity;
  final int soldCount;
  final double rating;
  final bool isActive;
  final DateTime createdAt;
  final String? imageUrl;
  final String? description;
  
  FarmerProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.soldCount,
    required this.rating,
    required this.isActive,
    required this.createdAt,
    this.imageUrl,
    this.description,
  });
  
  double get totalRevenue => price * soldCount;
  String get stockStatus => quantity > 0 ? 'In Stock' : 'Out of Stock';
  Color get stockColor => quantity > 50 ? Colors.green : (quantity > 10 ? Colors.orange : Colors.red);
  
  static List<FarmerProduct> getSampleProducts() {
    return [
      FarmerProduct(
        id: '1',
        name: 'Fresh Tomatoes',
        category: 'Vegetables',
        price: 50,
        unit: 'kg',
        quantity: 500,
        soldCount: 320,
        rating: 4.8,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      FarmerProduct(
        id: '2',
        name: 'Sweet Bananas',
        category: 'Fruits',
        price: 30,
        unit: 'dozen',
        quantity: 300,
        soldCount: 180,
        rating: 4.9,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      FarmerProduct(
        id: '3',
        name: 'Organic Maize',
        category: 'Cereals',
        price: 80,
        unit: 'kg',
        quantity: 1000,
        soldCount: 450,
        rating: 4.7,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }
}

class FarmerStats {
  final double totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int totalCustomers;
  final double averageRating;
  final double revenueGrowth;
  final int pendingOrders;
  final int completedOrders;
  
  FarmerStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalCustomers,
    required this.averageRating,
    required this.revenueGrowth,
    required this.pendingOrders,
    required this.completedOrders,
  });
  
  static FarmerStats getSampleStats() {
    return FarmerStats(
      totalRevenue: 125000,
      totalOrders: 156,
      totalProducts: 12,
      totalCustomers: 89,
      averageRating: 4.8,
      revenueGrowth: 23.5,
      pendingOrders: 5,
      completedOrders: 151,
    );
  }
}

class FarmerEarning {
  final DateTime date;
  final double amount;
  final int orders;
  
  FarmerEarning({
    required this.date,
    required this.amount,
    required this.orders,
  });
}
