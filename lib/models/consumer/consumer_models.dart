import 'package:flutter/material.dart';

class OrderSummary {
  final String id;
  final String farmerName;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final int itemCount;
  
  OrderSummary({
    required this.id,
    required this.farmerName,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.itemCount,
  });
  
  Color get statusColor {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'shipped':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
  
  IconData get statusIcon {
    switch (status) {
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'shipped':
        return Icons.local_shipping;
      default:
        return Icons.pending;
    }
  }
}

class SavedProduct {
  final String id;
  final String name;
  final double price;
  final String unit;
  final String farmerName;
  final double rating;
  final String imageUrl;
  final DateTime savedAt;
  
  SavedProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.farmerName,
    required this.rating,
    required this.imageUrl,
    required this.savedAt,
  });
}

class ConsumerStats {
  final int totalOrders;
  final double totalSpent;
  final int savedItems;
  final int activeOrders;
  
  ConsumerStats({
    required this.totalOrders,
    required this.totalSpent,
    required this.savedItems,
    required this.activeOrders,
  });
}
