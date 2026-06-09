import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final OrderService _orderService = OrderService();
  bool _isProcessing = false;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _showAddressForm = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final totalAmount = ref.watch(cartTotalAmountProvider);
    final totalItems = ref.watch(cartTotalItemsProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (cartItems.isNotEmpty && !_isProcessing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearCartDialog(),
            ),
        ],
      ),
      body: cartItems.isEmpty ? _buildEmptyCart() : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) => _buildCartItem(cartItems[index]),
            ),
          ),
          _buildCheckoutSection(totalItems, totalAmount, user),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add products from the marketplace', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Icon(Icons.shopping_bag, size: 40, color: Colors.green)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(item.farmerName, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  Text('KSh ${item.price}${item.unit}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 24),
                      onPressed: () {
                        if (item.quantity > 1) {
                          ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity - 1);
                        } else {
                          ref.read(cartProvider.notifier).removeItem(item.id);
                        }
                      },
                    ),
                    Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 24),
                      onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity + 1),
                    ),
                  ],
                ),
                Text('Total: KSh ${item.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(int totalItems, double totalAmount, User? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          if (_showAddressForm) ...[
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Delivery Address', prefixIcon: Icon(Icons.location_on)),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total ($totalItems items)', style: const TextStyle(fontSize: 16)),
              Text('KSh ${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
            ],
          ),
          const SizedBox(height: 16),
          if (!_showAddressForm)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () {
                  if (user == null) _showLoginRequired();
                  else setState(() => _showAddressForm = true);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), padding: const EdgeInsets.symmetric(vertical: 16)),
                child: user == null ? const Text('Login to Checkout') : const Text('Proceed to Checkout'),
              ),
            ),
          if (_showAddressForm)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : () => setState(() => _showAddressForm = false),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () => _placeOrder(totalAmount),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                    child: _isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Place Order'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(double totalAmount) async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter delivery address')));
      return;
    }
    setState(() => _isProcessing = true);
    final cartItems = ref.read(cartProvider);
    final user = FirebaseAuth.instance.currentUser;
    final itemsByFarmer = <String, List<CartItem>>{};
    for (var item in cartItems) itemsByFarmer.putIfAbsent(item.farmerName, () => []).add(item);
    for (var entry in itemsByFarmer.entries) {
      final items = entry.value;
      final orderTotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      await _orderService.createOrder(
        items: items.map((item) => {'id': item.id, 'name': item.name, 'price': double.parse(item.price), 'quantity': item.quantity, 'unit': item.unit}).toList(),
        totalAmount: orderTotal,
        deliveryAddress: _addressController.text,
        farmerId: user?.uid ?? '',
        farmerName: entry.key,
      );
    }
    ref.read(cartProvider.notifier).clearCart();
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed successfully!'), backgroundColor: Colors.green));
    Navigator.pop(context);
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Remove all items?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () { ref.read(cartProvider.notifier).clearCart(); Navigator.pop(context); }, child: const Text('Clear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showLoginRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to checkout'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pushNamed(context, '/login'); }, child: const Text('Login')),
        ],
      ),
    );
  }
}
