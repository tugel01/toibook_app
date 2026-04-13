class EventCardResponse {
  final int id;
  final String name;
  final String? confirmedDate;
  final String? coverImageUrl;

  EventCardResponse({
    required this.id,
    required this.name,
    this.confirmedDate,
    this.coverImageUrl,
  });

  factory EventCardResponse.fromJson(Map<String, dynamic> json) => EventCardResponse(
        id: json['id'],
        name: json['name'],
        confirmedDate: json['confirmedDate'],
        coverImageUrl: json['coverImageUrl'],
      );
}