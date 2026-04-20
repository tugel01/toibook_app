import 'package:toibook_app/models/chat/chat_message.dart';

enum ChatEventType {
  messageSent,
  messageDelivered,
  messageRead;

  static ChatEventType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'MESSAGE_SENT': return ChatEventType.messageSent;
      case 'MESSAGE_DELIVERED': return ChatEventType.messageDelivered;
      case 'MESSAGE_READ': return ChatEventType.messageRead;
      default: return ChatEventType.messageSent;
    }
  }
}

class ChatEvent {
  final ChatEventType type;
  final int conversationId;
  final int messageId;
  final int senderId;
  final String? text;
  final MessageStatus status;
  final String createdAt;
  final String? deliveredAt;
  final String? readAt;

  ChatEvent({
    required this.type,
    required this.conversationId,
    required this.messageId,
    required this.senderId,
    this.text,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    this.readAt,
  });

  factory ChatEvent.fromJson(Map<String, dynamic> json) => ChatEvent(
        type: ChatEventType.fromString(json['type']),
        conversationId: json['conversationId'],
        messageId: json['messageId'],
        senderId: json['senderId'],
        text: json['text'],
        status: MessageStatus.fromString(json['status']),
        createdAt: json['createdAt'],
        deliveredAt: json['deliveredAt'],
        readAt: json['readAt'],
      );
}