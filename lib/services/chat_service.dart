import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat/chat_models.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Send text message
  Future<bool> sendMessage(String receiverId, String message) async {
    if (message.trim().isEmpty) return false;
    if (currentUserId.isEmpty) return false;
    
    try {
      final conversationId = _getConversationId(currentUserId, receiverId);
      final timestamp = DateTime.now();
      
      final messageData = {
        'senderId': currentUserId,
        'receiverId': receiverId,
        'message': message.trim(),
        'timestamp': Timestamp.fromDate(timestamp),
        'isRead': false,
        'type': 'MessageType.text',
      };
      
      await _firestore
          .collection('chats')
          .doc(conversationId)
          .collection('messages')
          .add(messageData);
      
      await _firestore.collection('chats').doc(conversationId).set({
        'participants': [currentUserId, receiverId],
        'lastMessage': message.trim(),
        'lastMessageTime': Timestamp.fromDate(timestamp),
        'lastMessageSender': currentUserId,
        'updatedAt': Timestamp.fromDate(timestamp),
      }, SetOptions(merge: true));
      
      // Reset typing status
      await _setTypingStatus(receiverId, false);
      
      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Send image message
  Future<bool> sendImageMessage(String receiverId, File imageFile) async {
    try {
      final conversationId = _getConversationId(currentUserId, receiverId);
      final timestamp = DateTime.now();
      
      // Upload image to Firebase Storage
      final imageName = '${DateTime.now().millisecondsSinceEpoch}_${currentUserId}.jpg';
      final ref = _storage.ref().child('chat_images/$conversationId/$imageName');
      await ref.putFile(imageFile);
      final imageUrl = await ref.getDownloadURL();
      
      final messageData = {
        'senderId': currentUserId,
        'receiverId': receiverId,
        'message': '📷 Image',
        'imageUrl': imageUrl,
        'timestamp': Timestamp.fromDate(timestamp),
        'isRead': false,
        'type': 'MessageType.image',
      };
      
      await _firestore
          .collection('chats')
          .doc(conversationId)
          .collection('messages')
          .add(messageData);
      
      await _firestore.collection('chats').doc(conversationId).set({
        'participants': [currentUserId, receiverId],
        'lastMessage': '📷 Image',
        'lastMessageTime': Timestamp.fromDate(timestamp),
        'lastMessageSender': currentUserId,
        'updatedAt': Timestamp.fromDate(timestamp),
      }, SetOptions(merge: true));
      
      return true;
    } catch (e) {
      print('Error sending image: $e');
      return false;
    }
  }

  // Set typing status
  Future<void> setTypingStatus(String receiverId, bool isTyping) async {
    await _setTypingStatus(receiverId, isTyping);
  }
  
  Future<void> _setTypingStatus(String receiverId, bool isTyping) async {
    final conversationId = _getConversationId(currentUserId, receiverId);
    await _firestore.collection('chats').doc(conversationId).update({
      'typingUsers.$currentUserId': isTyping,
    }).catchError((e) {});
  }

  // Get typing status stream
  Stream<bool> getTypingStatus(String otherUserId) {
    final conversationId = _getConversationId(currentUserId, otherUserId);
    return _firestore
        .collection('chats')
        .doc(conversationId)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          if (data != null && data.containsKey('typingUsers')) {
            final typingUsers = data['typingUsers'] as Map<String, dynamic>;
            return typingUsers[otherUserId] == true;
          }
          return false;
        });
  }

  // Get messages stream
  Stream<List<ChatMessage>> getMessages(String otherUserId) {
    final conversationId = _getConversationId(currentUserId, otherUserId);
    
    return _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return ChatMessage(
              id: doc.id,
              senderId: data['senderId'] ?? '',
              receiverId: data['receiverId'] ?? '',
              message: data['message'] ?? '',
              timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isRead: data['isRead'] ?? false,
              imageUrl: data['imageUrl'],
              voiceUrl: data['voiceUrl'],
              voiceDuration: data['voiceDuration'],
              type: _getMessageType(data['type']),
            );
          }).toList();
        });
  }

  // Get conversations stream
  Stream<List<ChatConversation>> getConversations() {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
          final conversations = <ChatConversation>[];
          
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final participants = List<String>.from(data['participants']);
            final otherUserId = participants.firstWhere((id) => id != currentUserId);
            
            final userDoc = await _firestore.collection('users').doc(otherUserId).get();
            final userData = userDoc.data() ?? {};
            
            final lastMessageTime = (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now();
            
            final lastMessage = ChatMessage(
              id: '',
              senderId: data['lastMessageSender'] ?? '',
              receiverId: otherUserId,
              message: data['lastMessage'] ?? '',
              timestamp: lastMessageTime,
              isRead: false,
              type: MessageType.text,
            );
            
            final unreadSnapshot = await _firestore
                .collection('chats')
                .doc(doc.id)
                .collection('messages')
                .where('receiverId', isEqualTo: currentUserId)
                .where('isRead', isEqualTo: false)
                .get();
            
            conversations.add(ChatConversation(
              id: doc.id,
              otherUser: ChatUser(
                id: otherUserId,
                name: userData['name'] ?? 'User',
                profileImageUrl: userData['profileImageUrl'],
                userType: userData['userType'] ?? 'consumer',
                isOnline: false,
                lastSeen: DateTime.now(),
              ),
              lastMessage: lastMessage,
              unreadCount: unreadSnapshot.size,
            ));
          }
          
          conversations.sort((a, b) => b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp));
          return conversations;
        });
  }

  // Mark messages as read
  Future<void> markAsRead(String otherUserId) async {
    final conversationId = _getConversationId(currentUserId, otherUserId);
    
    final messages = await _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();
    
    for (var doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  MessageType _getMessageType(String? type) {
    if (type == 'MessageType.image') return MessageType.image;
    if (type == 'MessageType.voice') return MessageType.voice;
    return MessageType.text;
  }

  String _getConversationId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }
}
