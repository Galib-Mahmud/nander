class NotificationModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String title;
  final String message;
  final String type;
  final String? referenceId;
  bool isRead;
  bool isActionDone; // ← new
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.isActionDone,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      referenceId: json['referenceId']?.toString(),
      isRead: json['isRead'] == true,
      isActionDone: json['isActionDone'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}