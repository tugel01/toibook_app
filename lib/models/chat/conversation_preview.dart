class ConversationPreview {
  final int conversationId;
  final int otherParticipantId;
  final String otherParticipantName;
  final String? lastMessageText;
  final String? lastMessageCreatedAt;
  final int unreadCount;

  ConversationPreview({
    required this.conversationId,
    required this.otherParticipantId,
    required this.otherParticipantName,
    this.lastMessageText,
    this.lastMessageCreatedAt,
    required this.unreadCount,
  });

  factory ConversationPreview.fromJson(Map<String, dynamic> json) =>
      ConversationPreview(
        conversationId: json['conversationId'],
        otherParticipantId: json['otherParticipantId'],
        otherParticipantName: json['otherParticipantName'],
        lastMessageText: json['lastMessageText'],
        lastMessageCreatedAt: json['lastMessageCreatedAt'],
        unreadCount: json['unreadCount'],
      );
}