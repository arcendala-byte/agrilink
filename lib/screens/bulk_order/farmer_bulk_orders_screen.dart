import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/bulk_order_service.dart';
import '../../models/bulk_order/bulk_order_models.dart';

class FarmerBulkOrdersScreen extends StatefulWidget {
  const FarmerBulkOrdersScreen({super.key});

  @override
  State<FarmerBulkOrdersScreen> createState() => _FarmerBulkOrdersScreenState();
}

class _FarmerBulkOrdersScreenState extends State<FarmerBulkOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BulkOrderService _bulkOrderService = BulkOrderService();
  List<BulkOrder> _orders = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await _bulkOrderService.getFarmerBulkOrders().first;
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  List<BulkOrder> get _filteredOrders {
    if (_selectedFilter == 'all') return _orders;
    return _orders.where((order) {
      switch (_selectedFilter) {
        case 'pending':
          return order.status == BulkOrderStatus.pending;
        case 'confirmed':
          return order.status == BulkOrderStatus.confirmed;
        case 'processing':
          return order.status == BulkOrderStatus.processing;
        case 'ready':
          return order.status == BulkOrderStatus.ready;
        case 'delivered':
          return order.status == BulkOrderStatus.delivered;
        default:
          return true;
      }
    }).toList();
  }

  Future<void> _updateOrderStatus(BulkOrder order, BulkOrderStatus newStatus) async {
    await _bulkOrderService.updateOrderStatus(order.id, newStatus);
    await _loadOrders();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order status updated to ${_getStatusText(newStatus)}')),
    );
  }

  String _getStatusText(BulkOrderStatus status) {
    switch (status) {
      case BulkOrderStatus.pending: return 'Pending';
      case BulkOrderStatus.confirmed: return 'Confirmed';
      case BulkOrderStatus.processing: return 'Processing';
      case BulkOrderStatus.ready: return 'Ready for Pickup';
      case BulkOrderStatus.delivered: return 'Delivered';
      case BulkOrderStatus.cancelled: return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bulk Orders'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Please login to view bulk orders'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Orders'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Orders', icon: Icon(Icons.list)),
            Tab(text: 'Pending', icon: Icon(Icons.pending)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredOrders.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = _filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No bulk orders yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Bulk orders from retailers will appear here',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BulkOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: order.statusColor.withOpacity(0.2),
          child: Icon(
            _getStatusIcon(order.status),
            color: order.statusColor,
          ),
        ),
        title: Text(
          'Order #${order.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${order.retailerName}'),
            Text('Total: KSh ${order.total.toStringAsFixed(0)}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: order.statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            order.statusText,
            style: TextStyle(
              fontSize: 11,
              color: order.statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Details
                _buildInfoRow('Order ID', order.id),
                _buildInfoRow('Customer', order.retailerName),
                _buildInfoRow('Phone', order.phoneNumber),
                _buildInfoRow('Delivery Address', order.deliveryAddress),
                _buildInfoRow('Order Date', _formatDate(order.orderDate)),
                if (order.isRecurring) ...[
                  _buildInfoRow('Recurring', 'Yes (${order.recurringFrequency})'),
                  _buildInfoRow('Duration', '${order.recurringWeeks} weeks'),
                ],
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                // Order Items
                const Text(
                  'Order Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Quantity: ${item.quantity} ${item.unit}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'KSh ${item.totalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'KSh ${item.bulkPrice}/${item.unit}',
                                style: TextStyle(fontSize: 11, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const Divider(),
                const SizedBox(height: 8),
                
                // Pricing Summary
                _buildPriceRow('Subtotal', 'KSh ${order.subtotal.toStringAsFixed(0)}'),
                _buildPriceRow('Discount', '- KSh ${order.discount.toStringAsFixed(0)}', isHighlight: true),
                _buildPriceRow('Delivery Fee', 'KSh ${order.deliveryFee.toStringAsFixed(0)}'),
                const Divider(),
                _buildPriceRow('Total', 'KSh ${order.total.toStringAsFixed(0)}', isBold: true),
                
                const SizedBox(height: 16),
                
                // Action Buttons
                if (order.status == BulkOrderStatus.pending)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus(order, BulkOrderStatus.confirmed),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Confirm Order'),
                    ),
                  ),
                
                if (order.status == BulkOrderStatus.confirmed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus(order, BulkOrderStatus.processing),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Start Processing'),
                    ),
                  ),
                
                if (order.status == BulkOrderStatus.processing)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateOrderStatus(order, BulkOrderStatus.ready),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Mark Ready'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateOrderStatus(order, BulkOrderStatus.cancelled),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                
                if (order.status == BulkOrderStatus.ready)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus(order, BulkOrderStatus.delivered),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Mark Delivered'),
                    ),
                  ),
                
                if (order.notes != null && order.notes!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Notes:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(order.notes!),
                      ],
                    ),
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
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.green : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(BulkOrderStatus status) {
    switch (status) {
      case BulkOrderStatus.pending: return Icons.pending;
      case BulkOrderStatus.confirmed: return Icons.check_circle;
      case BulkOrderStatus.processing: return Icons.production_quantity_limits;
      case BulkOrderStatus.ready: return Icons.inventory;
      case BulkOrderStatus.delivered: return Icons.delivery_dining;
      case BulkOrderStatus.cancelled: return Icons.cancel;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
