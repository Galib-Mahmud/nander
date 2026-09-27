class ConversationModel {
  final String id;
  final String name;
  final String? profile;
  final bool isOnline;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.name,
    this.profile,
    required this.isOnline,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: ChatMessageModel.extractId(json['id'] ?? json['_id'] ?? json['peerId'] ?? json['user']),
      name: (json['name'] ?? json['fullName'] ?? json['userName'] ?? 'User').toString(),
      profile: json['profile']?.toString() ?? json['avatar']?.toString() ?? json['image']?.toString(),
      isOnline: json['isOnline'] == true || json['online'] == true,
      lastMessage: (json['lastMessage'] ?? json['last_message'] ?? '').toString(),
      lastMessageTime: DateTime.tryParse(json['lastMessageTime']?.toString() ??
              json['last_message_time']?.toString() ??
              json['updatedAt']?.toString() ??
              '') ??
          DateTime.now(),
      unreadCount: json['unreadCount'] is int
          ? json['unreadCount']
          : (int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0),
    );
  }
}

class ChatMessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  static String extractId(dynamic val) {
    if (val == null) return '';
    if (val is String) return val.trim();
    if (val is Map) {
      return (val['_id'] ?? val['id'] ?? val['userId'] ?? '').toString().trim();
    }
    return val.toString().trim();
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final rawSender = json['senderId'] ??
        json['sender_id'] ??
        json['sender'] ??
        json['from'] ??
        json['userId'];

    final rawReceiver = json['receiverId'] ??
        json['receiver_id'] ??
        json['receiver'] ??
        json['to'];

    return ChatMessageModel(
      id: extractId(json['id'] ?? json['_id']),
      senderId: extractId(rawSender),
      receiverId: extractId(rawReceiver),
      message: (json['message'] ?? json['text'] ?? json['content'] ?? '').toString(),
      isRead: json['isRead'] == true || json['read'] == true || json['seen'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ??
              json['created_at']?.toString() ??
              json['timestamp']?.toString() ??
              '') ??
          DateTime.now(),
    );
  }
}
