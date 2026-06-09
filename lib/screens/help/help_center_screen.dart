import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  final List<Map<String, dynamic>> _faqs = const [
    {
      'question': 'How do I place an order?',
      'answer': 'Add products to your cart, then proceed to checkout. Enter your delivery address and payment method to complete the order.',
    },
    {
      'question': 'How can I track my order?',
      'answer': 'Go to My Orders in your profile to track the status of your orders.',
    },
    {
      'question': 'What payment methods are accepted?',
      'answer': 'We accept M-Pesa, credit/debit cards, and bank transfers.',
    },
    {
      'question': 'How do I contact a farmer?',
      'answer': 'Use the chat feature on the product page to message the farmer directly.',
    },
    {
      'question': 'What is the delivery time?',
      'answer': 'Delivery usually takes 1-3 business days depending on your location.',
    },
    {
      'question': 'How do I cancel an order?',
      'answer': 'You can cancel an order from the order details page while it is still pending.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Contact Support Section
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.green.shade50,
            child: Column(
              children: [
                const Icon(Icons.support_agent, size: 50, color: Color(0xFF2E7D32)),
                const SizedBox(height: 12),
                const Text(
                  'Need Help?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our support team is here to assist you',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _contactSupport(context);
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Contact Support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // FAQ Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          
          // FAQ Items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqs.length,
            itemBuilder: (context, index) {
              final faq = _faqs[index];
              return ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ),
                title: Text(
                  faq['question'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      faq['answer'],
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Emergency Contacts
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                const Icon(Icons.emergency, size: 40, color: Colors.red),
                const SizedBox(height: 8),
                const Text(
                  'Emergency?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  'For urgent issues with your order delivery',
                  style: TextStyle(color: Colors.red.shade700),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.red),
                      onPressed: () {
                        launchUrl(Uri.parse('tel:+254700000000'));
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.email, color: Colors.red),
                      onPressed: () {
                        launchUrl(Uri.parse('mailto:support@agrilink.com'));
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.red),
                      onPressed: () {
                        _contactSupport(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Contact Support',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.chat, color: Color(0xFF2E7D32)),
                title: const Text('Live Chat'),
                subtitle: const Text('Chat with support agent'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Live chat coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Color(0xFF2E7D32)),
                title: const Text('Email Support'),
                subtitle: const Text('support@agrilink.com'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  launchUrl(Uri.parse('mailto:support@agrilink.com'));
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Color(0xFF2E7D32)),
                title: const Text('Phone Support'),
                subtitle: const Text('+254 700 000 000'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  launchUrl(Uri.parse('tel:+254700000000'));
                },
              ),
              ListTile(
                leading: const Icon(Icons.web, color: Color(0xFF2E7D32)),
                title: const Text('Visit Website'),
                subtitle: const Text('www.agrilink.com'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  launchUrl(Uri.parse('https://agrilink.com'));
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
