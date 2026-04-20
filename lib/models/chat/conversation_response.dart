class ConversationResponse {
  final int id;
  final int userId;
  final int vendorId;
  final String createdAt;
  final String updatedAt;

  ConversationResponse({
    required this.id,
    required this.userId,
    required this.vendorId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      ConversationResponse(
        id: json['id'],
        userId: json['userId'],
        vendorId: json['vendorId'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );
}