import 'package:flutter/material.dart';

class OrderStatusWidget extends StatelessWidget {
  final String status;
  final DateTime? orderDate;
  final DateTime? deliveryDate;

  const OrderStatusWidget({
    super.key,
    required this.status,
    this.orderDate,
    this.deliveryDate,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];
    final currentIndex = statuses.indexOf(status.toLowerCase());
    
    return Column(
      children: [
        Row(
          children: List.generate(statuses.length - 1, (index) {
            final isCompleted = index <= currentIndex && status != 'cancelled';
            final isCurrent = index == currentIndex;
            
            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                      border: isCurrent ? Border.all(color: const Color(0xFFFFA726), width: 2) : null,
                    ),
                    child: Icon(
                      _getStatusIcon(statuses[index]),
                      size: 16,
                      color: isCompleted ? Colors.white : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusLabel(statuses[index]),
                    style: TextStyle(
                      fontSize: 10,
                      color: isCompleted ? const Color(0xFF2E7D32) : Colors.grey.shade500,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        if (status == 'delivered' && deliveryDate != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivered Successfully',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Delivered on ${_formatDate(deliveryDate!)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (status == 'cancelled')
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.cancel, color: Colors.red.shade700),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Order Cancelled',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'confirmed':
        return Icons.check_circle;
      case 'processing':
        return Icons.production_quantity_limits;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.delivery_dining;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
