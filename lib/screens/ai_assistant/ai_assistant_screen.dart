import 'package:flutter/material.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(ChatMessage(
      text: "Hello! I'm your AI Farming Assistant. 🌱\n\nI can help you with:\n• Crop disease diagnosis\n• Pest identification\n• Fertilizer recommendations\n• Weather advice\n• Market prices\n\nHow can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Farming Assistant'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  text: "Chat cleared! How can I help you? 🌱",
                  isUser: false,
                  timestamp: DateTime.now(),
                ));
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[_messages.length - 1 - index]);
              },
            ),
          ),
          if (_isTyping) _buildTypingIndicator(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFF2E7D32)
              : Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade100
                  : Colors.grey.shade800,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : null,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: message.isUser ? Colors.white70 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.shade100
                : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask me anything about farming...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade100
                    : Colors.grey.shade800,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.insert(0, ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 1));
    
    final aiResponse = _getAIResponse(userMessage);
    
    setState(() {
      _messages.insert(0, ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = false;
    });
  }

  String _getAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('tomato') || message.contains('disease')) {
      return "Based on your description, here are common tomato diseases:\n\n"
             "🍅 **Early Blight**: Dark spots with concentric rings\n"
             "• Remove affected leaves\n"
             "• Apply copper-based fungicide\n"
             "• Ensure good air circulation\n\n"
             "🍅 **Late Blight**: Water-soaked spots on leaves\n"
             "• Remove infected plants\n"
             "• Apply copper fungicide\n"
             "• Avoid overhead watering\n\n"
             "Would you like more details about treating these?";
    }
    
    if (message.contains('price') || message.contains('market')) {
      return "📊 **Current Market Prices (Nairobi):**\n\n"
             "• Tomatoes: KSh 50-70/kg\n"
             "• Maize: KSh 80-100/kg\n"
             "• Beans: KSh 120-150/kg\n"
             "• Onions: KSh 60-80/kg\n"
             "• Potatoes: KSh 70-90/kg\n\n"
             "Prices are trending upward by 5-10% this week.";
    }
    
    if (message.contains('weather')) {
      return "🌤️ **Weather Forecast for Next 7 Days:**\n\n"
             "• Today: 24°C, Partly cloudy ☁️\n"
             "• Tomorrow: 26°C, Sunny ☀️\n"
             "• Wednesday: 23°C, Light rain 🌧️\n"
             "• Thursday: 25°C, Sunny ☀️\n\n"
             "💡 **Recommendation:** Good time for planting maize and beans.\n"
             "Avoid spraying pesticides on Wednesday.";
    }
    
    if (message.contains('fertilizer')) {
      return "🌱 **Fertilizer Recommendations:**\n\n"
             "**For Maize:**\n"
             "• DAP at planting: 50kg/acre\n"
             "• CAN top dressing: 50kg/acre\n\n"
             "**For Tomatoes:**\n"
             "• NPK 17:17:17: 30kg/acre\n"
             "• Calcium nitrate: 20kg/acre\n\n"
             "Apply fertilizer in the evening for best results.";
    }
    
    if (message.contains('pest')) {
      return "🐛 **Common Pest Control:**\n\n"
             "**Aphids:**\n"
             "• Use neem oil spray\n"
             "• Introduce ladybugs\n\n"
             "**Fall Armyworm:**\n"
             "• Early detection is key\n"
             "• Use biological pesticides\n"
             "• Practice crop rotation\n\n"
             "Need specific advice for a particular pest?";
    }
    
    return "I'm here to help! 🌱\n\n"
           "You can ask me about:\n"
           "• Crop diseases (e.g., 'tomato disease')\n"
           "• Market prices\n"
           "• Weather forecasts\n"
           "• Fertilizer recommendations\n"
           "• Pest control\n\n"
           "What would you like to know?";
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
