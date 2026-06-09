import 'package:flutter/material.dart';

enum OrderStatus {
  pending('Pending', Icons.pending, Colors.orange),
  confirmed('Confirmed', Icons.check_circle, Colors.blue),
  processing('Processing', Icons.production_quantity_limits, Colors.purple),
  packed('Packed', Icons.inventory, Colors.indigo),
  inTransit('In Transit', Icons.local_shipping, Colors.orange),
  delivered('Delivered', Icons.delivery_dining, Colors.green),
  cancelled('Cancelled', Icons.cancel, Colors.red);

  final String label;
  final IconData icon;
  final Color color;

  const OrderStatus(this.label, this.icon, this.color);
}

class OrderItem {
  final String id;
  final String productName;
  final int quantity;
  final double price;
  final String imageUrl;

  OrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl = '',
  });

  double get total => price * quantity;
}

class Order {
  final String id;
  final String orderNumber;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String deliveryAddress;
  final String farmerName;
  final String customerName;
  final String? trackingNumber;
  final String? notes;

  Order({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
    required this.deliveryAddress,
    required this.farmerName,
    required this.customerName,
    this.trackingNumber,
    this.notes,
  });

  double get progress {
    switch (status) {
      case OrderStatus.pending:
        return 0.0;
      case OrderStatus.confirmed:
        return 0.2;
      case OrderStatus.processing:
        return 0.4;
      case OrderStatus.packed:
        return 0.6;
      case OrderStatus.inTransit:
        return 0.8;
      case OrderStatus.delivered:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
    }
  }

  String get estimatedDelivery {
    if (deliveryDate != null) {
      return 'Delivered on ${_formatDate(deliveryDate!)}';
    }

    switch (status) {
      case OrderStatus.pending:
        return 'Estimated: Tomorrow';
      case OrderStatus.confirmed:
        return 'Estimated: Tomorrow';
      case OrderStatus.processing:
        return 'Estimated: 2-3 days';
      case OrderStatus.packed:
        return 'Estimated: 2-3 days';
      case OrderStatus.inTransit:
        return 'Estimated: Today or Tomorrow';
      default:
        return 'Processing';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static List<Order> getSampleOrders() {
    return [
      Order(
        id: '1',
        orderNumber: 'AGR-2024-001',
        items: [
          OrderItem(id: '1', productName: 'Fresh Tomatoes', quantity: 5, price: 50),
          OrderItem(id: '2', productName: 'Sweet Bananas', quantity: 2, price: 30),
        ],
        subtotal: 310,
        deliveryFee: 50,
        total: 360,
        status: OrderStatus.inTransit,
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        deliveryAddress: '123 Farm Road, Nairobi',
        farmerName: 'Green Acres Farm',
        customerName: 'John Doe',
        trackingNumber: 'TRK123456789',
      ),
      Order(
        id: '2',
        orderNumber: 'AGR-2024-002',
        items: [
          OrderItem(id: '3', productName: 'Organic Maize', quantity: 10, price: 80),
        ],
        subtotal: 800,
        deliveryFee: 100,
        total: 900,
        status: OrderStatus.delivered,
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        deliveryDate: DateTime.now().subtract(const Duration(days: 3)),
        deliveryAddress: '456 Market Street, Nairobi',
        farmerName: 'Golden Grain Farm',
        customerName: 'John Doe',
        trackingNumber: 'TRK987654321',
      ),
      Order(
        id: '3',
        orderNumber: 'AGR-2024-003',
        items: [
          OrderItem(id: '4', productName: 'Free-range Eggs', quantity: 24, price: 15),
          OrderItem(id: '1', productName: 'Fresh Tomatoes', quantity: 3, price: 50),
        ],
        subtotal: 510,
        deliveryFee: 50,
        total: 560,
        status: OrderStatus.pending,
        orderDate: DateTime.now(),
        deliveryAddress: '789 Home Avenue, Nairobi',
        farmerName: 'Happy Hens Farm',
        customerName: 'John Doe',
      ),
    ];
  }
}
