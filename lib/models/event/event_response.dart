class EventResponse {
  final int id;
  final String name;
  final String description;
  final int guestCount;
  final double budget;
  final DateTime? confirmedDate;
  final String? coverImageUrl;
  final DateTime createdAt;

  EventResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.guestCount,
    required this.budget,
    this.confirmedDate,
    this.coverImageUrl,
    required this.createdAt,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) => EventResponse(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    guestCount: json['guestCount'],
    budget: (json['budget'] as num).toDouble(),
    confirmedDate:
        json['confirmedDate'] != null
            ? DateTime.parse(json['confirmedDate'])
            : null,
    coverImageUrl: json['coverImageUrl'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
