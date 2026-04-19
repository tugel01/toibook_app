enum TicketStatus {
  saved,
  pending,
  approved,
  rejected;

  static TicketStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SAVED': return TicketStatus.saved;
      case 'PENDING': return TicketStatus.pending;
      case 'APPROVED': return TicketStatus.approved;
      case 'REJECTED': return TicketStatus.rejected;
      default: return TicketStatus.saved;
    }
  }
}

class TicketCardResponse {
  final int id;
  final int eventId;
  final int offerId;
  final String eventName;
  final String eventDescription;
  final String? messageToVendor;
  final TicketStatus status;
  final String createdAt;

  TicketCardResponse({
    required this.id,
    required this.eventId,
    required this.offerId,
    required this.eventName,
    required this.eventDescription,
    this.messageToVendor,
    required this.status,
    required this.createdAt,
  });

  bool get isContacted => status != TicketStatus.saved;

  factory TicketCardResponse.fromJson(Map<String, dynamic> json) =>
      TicketCardResponse(
        id: json['id'],
        eventId: json['eventId'],
        offerId: json['offerId'],
        eventName: json['eventName'],
        eventDescription: json['eventDescription'],
        messageToVendor: json['messageToVendor'],
        status: TicketStatus.fromString(json['status']),
        createdAt: json['created_At'],
      );
}