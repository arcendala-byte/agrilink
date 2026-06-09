import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../language/language_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _emailUpdates = true;
  bool _smsUpdates = false;
  String _language = 'English';
  String _currency = 'KSh';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadLanguage();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
      _emailUpdates = prefs.getBool('emailUpdates') ?? true;
      _smsUpdates = prefs.getBool('smsUpdates') ?? false;
    });
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    setState(() {
      _language = languageCode == 'en' ? 'English' : 'Kiswahili';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setBool('darkMode', _darkModeEnabled);
    await prefs.setBool('emailUpdates', _emailUpdates);
    await prefs.setBool('smsUpdates', _smsUpdates);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Preferences'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch to dark theme'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() => _darkModeEnabled = value);
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive order updates and offers'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
            secondary: const Icon(Icons.notifications),
          ),
          
          _buildSectionHeader('Communication'),
          SwitchListTile(
            title: const Text('Email Updates'),
            subtitle: const Text('Receive email about orders and promotions'),
            value: _emailUpdates,
            onChanged: (value) {
              setState(() => _emailUpdates = value);
            },
            secondary: const Icon(Icons.email),
          ),
          SwitchListTile(
            title: const Text('SMS Updates'),
            subtitle: const Text('Receive SMS about order status'),
            value: _smsUpdates,
            onChanged: (value) {
              setState(() => _smsUpdates = value);
            },
            secondary: const Icon(Icons.sms),
          ),
          
          _buildSectionHeader('Regional'),
          // Language Selection
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF2E7D32)),
            title: const Text('Language'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LanguageSelectionScreen()),
              );
              _loadLanguage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Currency'),
            subtitle: Text(_currency),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showCurrencyDialog();
            },
          ),
          
          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.cloud_download),
            title: const Text('Clear Cache'),
            subtitle: const Text('Clear temporary data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showClearCacheDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.data_usage),
            title: const Text('Data Usage'),
            subtitle: const Text('View data usage statistics'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          
          _buildSectionHeader('Support'),
          ListTile(
            leading: const Icon(Icons.rate_review),
            title: const Text('Rate Us'),
            subtitle: const Text('Rate AgriLink on the store'),
            trailing: const Icon(Icons.star_border),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share App'),
            subtitle: const Text('Share AgriLink with friends'),
            trailing: const Icon(Icons.share),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Kenyan Shilling (KSh)'),
              leading: Radio<String>(
                value: 'KSh',
                groupValue: _currency,
                onChanged: (value) {
                  setState(() => _currency = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('US Dollar (USD)'),
              leading: Radio<String>(
                value: 'USD',
                groupValue: _currency,
                onChanged: (value) {
                  setState(() => _currency = value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear all cached data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
