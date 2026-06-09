import 'package:flutter/material.dart';

class OffersDealsScreen extends StatelessWidget {
  const OffersDealsScreen({super.key});

  final List<Map<String, dynamic>> _offers = const [
    {
      'title': '20% Off Vegetables',
      'description': 'Get 20% off on all vegetables',
      'code': 'VEG20',
      'expiry': 'Dec 31, 2024',
      'icon': Icons.agriculture,
      'color': Color(0xFF4CAF50),
    },
    {
      'title': 'Free Delivery',
      'description': 'Free delivery on orders above KSh 1000',
      'code': 'FREESHIP',
      'expiry': 'Dec 31, 2024',
      'icon': Icons.local_shipping,
      'color': Color(0xFFFF9800),
    },
    {
      'title': 'Buy 1 Get 1 Free',
      'description': 'On selected fruits',
      'code': 'BOGO',
      'expiry': 'Nov 30, 2024',
      'icon': Icons.apple,
      'color': Color(0xFFE91E63),
    },
    {
      'title': 'First Order Discount',
      'description': '10% off on your first order',
      'code': 'WELCOME10',
      'expiry': 'Dec 31, 2024',
      'icon': Icons.card_giftcard,
      'color': Color(0xFF2196F3),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers & Deals'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _offers.length,
        itemBuilder: (context, index) {
          final offer = _offers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [offer['color'].withOpacity(0.1), offer['color'].withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: offer['color'].withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(offer['icon'], color: offer['color'], size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer['title'],
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(offer['description'], style: TextStyle(color: Colors.grey.shade600)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: offer['color'].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Code: ${offer['code']}',
                                      style: TextStyle(color: offer['color'], fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Expires: ${offer['expiry']}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.grey),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Copied ${offer['code']} to clipboard')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
