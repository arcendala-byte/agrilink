import 'package:flutter/material.dart';

enum BulkOrderStatus {
  pending,
  confirmed,
  processing,
  ready,
  delivered,
  cancelled,
}

class BulkOrderItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String unit;
  final double bulkPrice;
  final int bulkQuantity;
  
  BulkOrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
    required this.bulkPrice,
    required this.bulkQuantity,
  });
  
  double get totalPrice => quantity * bulkPrice;
  double get discountSaved => quantity * (unitPrice - bulkPrice);
  
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'unit': unit,
    'bulkPrice': bulkPrice,
    'bulkQuantity': bulkQuantity,
  };
}

class BulkOrder {
  final String id;
  final String retailerId;
  final String retailerName;
  final String farmerId;
  final String farmerName;
  final List<BulkOrderItem> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final BulkOrderStatus status;
  final String deliveryAddress;
  final String phoneNumber;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? notes;
  final bool isRecurring;
  final String? recurringFrequency; // weekly, biweekly, monthly
  final int? recurringWeeks;
  
  BulkOrder({
    required this.id,
    required this.retailerId,
    required this.retailerName,
    required this.farmerId,
    required this.farmerName,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    required this.phoneNumber,
    required this.orderDate,
    this.deliveryDate,
    this.notes,
    this.isRecurring = false,
    this.recurringFrequency,
    this.recurringWeeks,
  });
  
  String get statusText {
    switch (status) {
      case BulkOrderStatus.pending:
        return 'Pending';
      case BulkOrderStatus.confirmed:
        return 'Confirmed';
      case BulkOrderStatus.processing:
        return 'Processing';
      case BulkOrderStatus.ready:
        return 'Ready for Pickup';
      case BulkOrderStatus.delivered:
        return 'Delivered';
      case BulkOrderStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case BulkOrderStatus.pending:
        return Colors.orange;
      case BulkOrderStatus.confirmed:
        return Colors.blue;
      case BulkOrderStatus.processing:
        return Colors.purple;
      case BulkOrderStatus.ready:
        return Colors.teal;
      case BulkOrderStatus.delivered:
        return Colors.green;
      case BulkOrderStatus.cancelled:
        return Colors.red;
    }
  }
}
