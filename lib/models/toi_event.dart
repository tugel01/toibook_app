class ToiEvent {
  final String id;
  final String userId;
  final String title;
  final String type;
  final DateTime date;
  final String? location;
  final int? guestCount;
  final double? budget;
  final String? imageUrl;

  ToiEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.date,
    this.location,
    this.guestCount,
    this.budget,
    this.imageUrl
  });

  // Mock data with different owners
  static List<ToiEvent> mockEvents = [
    ToiEvent(
      id: 'e1',
      userId: 'u-admin',
      title: 'Admin Wedding',
      type: 'Үйлену той',
      date: DateTime(2026, 8, 20),
    ),
    ToiEvent(
      id: 'e2',
      userId: 'u-user123',
      title: 'Sanzhar Birthday',
      type: 'Birthday',
      date: DateTime(2026, 12, 10),
    ),
  ];
}