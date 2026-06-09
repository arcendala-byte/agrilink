import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  String _filterStatus = 'all';

  final List<String> _statuses = ['all', 'pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Management'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filterStatus = value);
            },
            itemBuilder: (context) {
              return _statuses.map((status) {
                return PopupMenuItem(
                  value: status,
                  child: Text(status.toUpperCase()),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('orderDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          var orders = snapshot.data!.docs;
          
          if (_filterStatus != 'all') {
            orders = orders.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == _filterStatus;
            }).toList();
          }
          
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;
              return _buildOrderCard(order.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(String orderId, Map<String, dynamic> data) {
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final totalAmount = data['totalAmount'] ?? 0;
    final status = data['status'] ?? 'pending';
    final farmerName = data['farmerName'] ?? 'Farmer';
    final userId = data['userId'] ?? '';
    final orderDate = (data['orderDate'] as Timestamp?)?.toDate();
    
    Color statusColor;
    switch (status) {
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'shipped':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Text(
            items.length.toString(),
            style: TextStyle(color: statusColor),
          ),
        ),
        title: Text(
          'Order #${orderId.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: $farmerName'),
            Text(
              'Total: KSh ${totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Order ID', orderId),
                if (orderDate != null) _buildInfoRow('Order Date', _formatDate(orderDate)),
                _buildInfoRow('Customer ID', userId),
                _buildInfoRow('Farmer', farmerName),
                _buildInfoRow('Delivery Address', data['deliveryAddress'] ?? 'N/A'),
                const SizedBox(height: 12),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('• ${item['quantity']}x ${item['name']} - KSh ${item['price']}/${item['unit']}'),
                )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (status == 'pending')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _updateOrderStatus(orderId, 'confirmed');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Confirm'),
                        ),
                      ),
                    if (status == 'confirmed')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _updateOrderStatus(orderId, 'shipped');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Ship'),
                        ),
                      ),
                    if (status == 'shipped')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _updateOrderStatus(orderId, 'delivered');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Mark Delivered'),
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (status != 'delivered' && status != 'cancelled')
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _updateOrderStatus(orderId, 'cancelled');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order status updated to $newStatus')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
