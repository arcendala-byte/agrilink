import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/chat_service.dart';
import '../../models/chat/chat_models.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _availableUsers = [];
  bool _showUserList = false;
  bool _loadingUsers = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadAvailableUsers();
  }

  Future<void> _loadAvailableUsers() async {
    final user = _currentUser;
    if (user == null) return;
    
    setState(() => _loadingUsers = true);
    
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: user.uid)
        .get();
    
    setState(() {
      _availableUsers = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'name': data['name'] ?? 'User',
          'email': data['email'] ?? '',
          'userType': data['userType'] ?? 'consumer',
        };
      }).toList();
      _loadingUsers = false;
    });
  }

  void _startNewChat(String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          otherUserId: userId,
          otherUserName: userName,
          otherUserImage: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Login to chat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to start messaging with farmers and buyers',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: () {
              setState(() => _showUserList = !_showUserList);
              if (!_showUserList) _loadAvailableUsers();
            },
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // New Chat User List
          if (_showUserList)
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: _loadingUsers
                  ? const Center(child: CircularProgressIndicator())
                  : _availableUsers.isEmpty
                      ? const Center(
                          child: Text('No other users found'),
                        )
                      : ListView.builder(
                          itemCount: _availableUsers.length,
                          itemBuilder: (context, index) {
                            final chatUser = _availableUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getRoleColor(chatUser['userType']),
                                child: Icon(
                                  _getRoleIcon(chatUser['userType']),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(chatUser['name']),
                              subtitle: Text(chatUser['userType'].toUpperCase()),
                              trailing: const Icon(Icons.chat, color: Color(0xFF2E7D32)),
                              onTap: () {
                                setState(() => _showUserList = false);
                                _startNewChat(chatUser['uid'], chatUser['name']);
                              },
                            );
                          },
                        ),
            ),
          
          // Chat List
          Expanded(
            child: StreamBuilder<List<ChatConversation>>(
              stream: _chatService.getConversations(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 80, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final conversations = snapshot.data ?? [];

                if (conversations.isEmpty && !_showUserList) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to start a conversation',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return _buildConversationTile(conversation);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(ChatConversation conversation) {
    final user = _currentUser;
    final isCurrentUserSender = conversation.lastMessage.senderId == user?.uid;
    
    return GestureDetector(
      onTap: () async {
        await _chatService.markAsRead(conversation.otherUser.id);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                otherUserId: conversation.otherUser.id,
                otherUserName: conversation.otherUser.name,
                otherUserImage: conversation.otherUser.profileImageUrl,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.green.shade100,
                  backgroundImage: conversation.otherUser.profileImageUrl != null
                      ? NetworkImage(conversation.otherUser.profileImageUrl!)
                      : null,
                  child: conversation.otherUser.profileImageUrl == null
                      ? Icon(_getRoleIcon(conversation.otherUser.userType), 
                            size: 30, color: Colors.green.shade700)
                      : null,
                ),
                if (conversation.otherUser.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUser.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(conversation.lastMessage.timestamp),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isCurrentUserSender)
                        const Icon(Icons.check, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          conversation.lastMessage.message,
                          style: TextStyle(
                            fontSize: 13,
                            color: conversation.unreadCount > 0 && !isCurrentUserSender
                                ? Colors.black
                                : Colors.grey.shade600,
                            fontWeight: conversation.unreadCount > 0 && !isCurrentUserSender
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0 && !isCurrentUserSender)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'farmer':
        return const Color(0xFF2E7D32);
      case 'transporter':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'farmer':
        return Icons.agriculture;
      case 'transporter':
        return Icons.local_shipping;
      default:
        return Icons.shopping_cart;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 7) {
      return '${time.day}/${time.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
