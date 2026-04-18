class EventDateDto {
  final DateTime startDate;
  final DateTime endDate;

  EventDateDto({required this.startDate, required this.endDate});

  Map<String, dynamic> toJson() => {
    'startDate': _format(startDate),
    'endDate': _format(endDate),
  };

  String _format(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
