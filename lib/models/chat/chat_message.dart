enum MessageStatus {
  sent,
  delivered,
  read;

  static MessageStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SENT': return MessageStatus.sent;
      case 'DELIVERED': return MessageStatus.delivered;
      case 'READ': return MessageStatus.read;
      default: return MessageStatus.sent;
    }
  }
}

class ChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String text;
  final MessageStatus status;
  final String createdAt;
  final String? deliveredAt;
  final String? readAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    this.readAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        conversationId: json['conversationId'],
        senderId: json['senderId'],
        text: json['text'],
        status: MessageStatus.fromString(json['status']),
        createdAt: json['createdAt'],
        deliveredAt: json['deliveredAt'],
        readAt: json['readAt'],
      );

  ChatMessage copyWith({MessageStatus? status, String? deliveredAt, String? readAt}) =>
      ChatMessage(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        text: text,
        status: status ?? this.status,
        createdAt: createdAt,
        deliveredAt: deliveredAt ?? this.deliveredAt,
        readAt: readAt ?? this.readAt,
      );
}