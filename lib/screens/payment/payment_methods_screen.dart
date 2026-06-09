import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _isMpesaEnabled = true;
  bool _isCardEnabled = false;
  bool _isBankEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Add New'),
          ),
        ],
      ),
      body: ListView(
        children: [
          // M-Pesa
          _buildPaymentMethod(
            icon: Icons.phone_android,
            title: 'M-Pesa',
            subtitle: 'Pay with mobile money',
            isEnabled: _isMpesaEnabled,
            onTap: () {
              setState(() => _isMpesaEnabled = !_isMpesaEnabled);
            },
            onEdit: () {
              _showMpesaDialog();
            },
          ),
          const Divider(),
          
          // Credit/Debit Card
          _buildPaymentMethod(
            icon: Icons.credit_card,
            title: 'Credit / Debit Card',
            subtitle: 'Visa, Mastercard, American Express',
            isEnabled: _isCardEnabled,
            onTap: () {
              setState(() => _isCardEnabled = !_isCardEnabled);
            },
            onEdit: () {
              _showCardDialog();
            },
          ),
          const Divider(),
          
          // Bank Transfer
          _buildPaymentMethod(
            icon: Icons.account_balance,
            title: 'Bank Transfer',
            subtitle: 'Direct bank transfer',
            isEnabled: _isBankEnabled,
            onTap: () {
              setState(() => _isBankEnabled = !_isBankEnabled);
            },
            onEdit: () {
              _showBankDialog();
            },
          ),
          
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Default payment method will be used for automatic payments',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required VoidCallback onTap,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.green.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (_) => onTap(),
            activeColor: const Color(0xFF2E7D32),
          ),
          if (isEnabled)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }

  void _showMpesaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('M-Pesa Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '0712345678',
                prefixIcon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Card Number',
                hintText: '**** **** **** ****',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Expiry', hintText: 'MM/YY'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'CVV', hintText: '***'),
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }

  void _showBankDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bank Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Bank Name')),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Account Name')),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Account Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
