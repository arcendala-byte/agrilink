class ChatUser {
  final String id;
  final String name;
  final String? profileImageUrl;
  final String userType;
  final bool isOnline;
  final DateTime lastSeen;
  final bool isTyping;
  
  ChatUser({
    required this.id,
    required this.name,
    this.profileImageUrl,
    required this.userType,
    this.isOnline = false,
    required this.lastSeen,
    this.isTyping = false,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'profileImageUrl': profileImageUrl,
    'userType': userType,
    'isOnline': isOnline,
    'lastSeen': lastSeen.toIso8601String(),
    'isTyping': isTyping,
  };
  
  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      name: json['name'],
      profileImageUrl: json['profileImageUrl'],
      userType: json['userType'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: DateTime.parse(json['lastSeen']),
      isTyping: json['isTyping'] ?? false,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? voiceUrl;
  final int? voiceDuration;
  final MessageType type;
  
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.voiceUrl,
    this.voiceDuration,
    this.type = MessageType.text,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'imageUrl': imageUrl,
    'voiceUrl': voiceUrl,
    'voiceDuration': voiceDuration,
    'type': type.toString(),
  };
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      imageUrl: json['imageUrl'],
      voiceUrl: json['voiceUrl'],
      voiceDuration: json['voiceDuration'],
      type: json['type'] == 'MessageType.image' ? MessageType.image :
             json['type'] == 'MessageType.voice' ? MessageType.voice :
             MessageType.text,
    );
  }
}

enum MessageType {
  text,
  image,
  voice,
}

class ChatConversation {
  final String id;
  final ChatUser otherUser;
  final ChatMessage lastMessage;
  final int unreadCount;
  
  ChatConversation({
    required this.id,
    required this.otherUser,
    required this.lastMessage,
    required this.unreadCount,
  });
}
