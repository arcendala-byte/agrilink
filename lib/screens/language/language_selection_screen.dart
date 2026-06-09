import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/language_provider.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildLanguageTile(
            context,
            'English',
            'English',
            '🇬🇧',
            'en',
            ref,
            currentLocale,
          ),
          _buildLanguageTile(
            context,
            'Kiswahili',
            'Swahili',
            '🇹🇿',
            'sw',
            ref,
            currentLocale,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLanguageTile(
    BuildContext context,
    String title,
    String subtitle,
    String flag,
    String languageCode,
    WidgetRef ref,
    Locale currentLocale,
  ) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 30)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: currentLocale.languageCode == languageCode
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () {
        ref.read(languageProvider.notifier).setLanguage(languageCode);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Language changed to $title')),
        );
      },
    );
  }
}
