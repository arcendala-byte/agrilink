import 'package:flutter/material.dart';

class DeliveryAddressesScreen extends StatefulWidget {
  const DeliveryAddressesScreen({super.key});

  @override
  State<DeliveryAddressesScreen> createState() => _DeliveryAddressesScreenState();
}

class _DeliveryAddressesScreenState extends State<DeliveryAddressesScreen> {
  List<Map<String, dynamic>> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    setState(() {
      _addresses = [
        {
          'id': '1',
          'name': 'Home',
          'address': '123 Farm Road, Nairobi',
          'phone': '0712345678',
          'isDefault': true,
        },
        {
          'id': '2',
          'name': 'Office',
          'address': '456 Business Park, Nairobi',
          'phone': '0723456789',
          'isDefault': false,
        },
      ];
    });
  }

  void _addAddress() {
    _showAddressDialog();
  }

  void _editAddress(Map<String, dynamic> address) {
    _showAddressDialog(address: address);
  }

  void _deleteAddress(String id) {
    setState(() {
      _addresses.removeWhere((a) => a['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address deleted')),
    );
  }

  void _setDefaultAddress(String id) {
    setState(() {
      for (var address in _addresses) {
        address['isDefault'] = address['id'] == id;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default address updated')),
    );
  }

  void _showAddressDialog({Map<String, dynamic>? address}) {
    final isEditing = address != null;
    final nameController = TextEditingController(text: address?['name']);
    final addressController = TextEditingController(text: address?['address']);
    final phoneController = TextEditingController(text: address?['phone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Address' : 'Add New Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Address Label', hintText: 'Home, Office, etc.'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address', hintText: 'Street, City'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && addressController.text.isNotEmpty) {
                if (isEditing) {
                  setState(() {
                    final index = _addresses.indexWhere((a) => a['id'] == address['id']);
                    if (index != -1) {
                      _addresses[index] = {
                        ..._addresses[index],
                        'name': nameController.text,
                        'address': addressController.text,
                        'phone': phoneController.text,
                      };
                    }
                  });
                } else {
                  setState(() {
                    _addresses.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'name': nameController.text,
                      'address': addressController.text,
                      'phone': phoneController.text,
                      'isDefault': _addresses.isEmpty,
                    });
                  });
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Addresses'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAddress,
          ),
        ],
      ),
      body: _addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No addresses saved',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a delivery address to get started',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _addAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Address'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: address['isDefault'] ? Colors.green : Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              address['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: address['isDefault'] ? Colors.green : null,
                              ),
                            ),
                            if (address['isDefault']) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Default',
                                  style: TextStyle(fontSize: 10, color: Colors.green),
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (!address['isDefault'])
                              TextButton(
                                onPressed: () => _setDefaultAddress(address['id']),
                                child: const Text('Set Default'),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editAddress(address),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _deleteAddress(address['id']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(address['address']),
                        const SizedBox(height: 4),
                        Text(
                          'Phone: ${address['phone']}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
