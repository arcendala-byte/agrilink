import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/bulk_pricing_calculator.dart';
import '../../services/bulk_order_service.dart';
import '../../models/bulk_order/bulk_order_models.dart';

class BulkOrderScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final double unitPrice;
  final String unit;
  final String farmerId;
  final String farmerName;

  const BulkOrderScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.unit,
    required this.farmerId,
    required this.farmerName,
  });

  @override
  State<BulkOrderScreen> createState() => _BulkOrderScreenState();
}

class _BulkOrderScreenState extends State<BulkOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isRecurring = false;
  String _recurringFrequency = 'weekly';
  int _recurringWeeks = 4;
  bool _isLoading = false;
  
  double _bulkPrice = 0;
  double _totalPrice = 0;
  double _discount = 0;
  int _quantity = 0;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_updatePricing);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updatePricing() {
    final qty = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _quantity = qty;
      if (qty > 0) {
        _bulkPrice = BulkPricingCalculator.getBulkPrice(widget.unitPrice, qty);
        _totalPrice = _bulkPrice * qty;
        _discount = (widget.unitPrice - _bulkPrice) * qty;
      } else {
        _bulkPrice = widget.unitPrice;
        _totalPrice = 0;
        _discount = 0;
      }
    });
  }

  Future<void> _submitBulkOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_quantity < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum bulk order quantity is 10 units')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final orderItem = BulkOrderItem(
      productId: widget.productId,
      productName: widget.productName,
      unitPrice: widget.unitPrice,
      quantity: _quantity,
      unit: widget.unit,
      bulkPrice: _bulkPrice,
      bulkQuantity: _quantity,
    );

    final subtotal = widget.unitPrice * _quantity;
    final discount = _discount;
    final deliveryFee = _totalPrice > 10000 ? 0.0 : 500.0; // Free delivery over KSh 10,000
    final total = _totalPrice + deliveryFee;

    final orderService = BulkOrderService();
    final orderId = await orderService.createBulkOrder(
      items: [orderItem],
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      total: total,
      deliveryAddress: _addressController.text,
      phoneNumber: _phoneController.text,
      farmerId: widget.farmerId,
      farmerName: widget.farmerName,
      isRecurring: _isRecurring,
      recurringFrequency: _isRecurring ? _recurringFrequency : null,
      recurringWeeks: _isRecurring ? _recurringWeeks : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    setState(() => _isLoading = false);

    if (orderId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bulk order placed successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Order'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.shopping_bag, size: 30, color: Colors.green),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.productName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'From: ${widget.farmerName}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Regular Price:'),
                          Text('KSh ${widget.unitPrice.toStringAsFixed(0)}/${widget.unit}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Bulk Pricing Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📦 Bulk Discounts',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ...BulkPricingCalculator.bulkDiscounts.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${entry.key}+ units:'),
                            Text('${(entry.value * 100).toInt()}% off'),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity (minimum 10)',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  helperText: 'Order in bulk to get discounts',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter quantity';
                  final qty = int.tryParse(value);
                  if (qty == null) return 'Enter valid number';
                  if (qty < 10) return 'Minimum quantity is 10';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Pricing Breakdown
              if (_quantity >= 10) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildPriceRow('Unit Price:', 'KSh ${widget.unitPrice.toStringAsFixed(0)}'),
                        _buildPriceRow('Bulk Price:', 'KSh ${_bulkPrice.toStringAsFixed(0)}'),
                        _buildPriceRow('Total:', 'KSh ${_totalPrice.toStringAsFixed(0)}', isBold: true),
                        const Divider(),
                        _buildPriceRow('Discount Saved:', 'KSh ${_discount.toStringAsFixed(0)}', isHighlight: true),
                        if (_totalPrice > 10000)
                          _buildPriceRow('Delivery:', 'Free', isHighlight: true)
                        else
                          _buildPriceRow('Delivery Fee:', 'KSh 500'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Delivery Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                maxLines: 2,
                validator: (value) => value?.isEmpty == true ? 'Enter delivery address' : null,
              ),
              const SizedBox(height: 12),
              
              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty == true ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 12),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Special Instructions (Optional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              
              // Recurring Order
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Schedule Recurring Order'),
                      subtitle: const Text('Get deliveries on a regular schedule'),
                      value: _isRecurring,
                      onChanged: (value) {
                        setState(() => _isRecurring = value);
                      },
                      secondary: const Icon(Icons.repeat),
                    ),
                    if (_isRecurring) ...[
                      const Divider(),
                      ListTile(
                        title: const Text('Frequency'),
                        subtitle: Text(_recurringFrequency.toUpperCase()),
                        trailing: DropdownButton<String>(
                          value: _recurringFrequency,
                          items: const [
                            DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                            DropdownMenuItem(value: 'biweekly', child: Text('Every 2 Weeks')),
                            DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                          ],
                          onChanged: (value) {
                            setState(() => _recurringFrequency = value!);
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Duration (weeks)'),
                        subtitle: Text('$_recurringWeeks weeks'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (_recurringWeeks > 1) {
                                  setState(() => _recurringWeeks--);
                                }
                              },
                            ),
                            Text('$_recurringWeeks'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() => _recurringWeeks++);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBulkOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Place Bulk Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.green : null,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
