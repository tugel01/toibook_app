import 'package:toibook_app/models/event_date_dto.dart';
import 'package:toibook_app/models/expense_dto.dart';
import 'package:toibook_app/models/expense_type.dart';

enum DateSelectionMode {
  singleDate,
  dateRange,
  multipleDates;

  String toBackendString() {
    switch (this) {
      case DateSelectionMode.singleDate: return 'SINGLE_DATE';
      case DateSelectionMode.dateRange: return 'DATE_RANGE';
      case DateSelectionMode.multipleDates: return 'MULTIPLE_DATES';
    }
  }
}

class ToiEvent {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateSelectionMode dateMode;
  final List<EventDateDto> dates;
  final int guestCount;
  final double budget;
  final String? imageUrl;
  final List<ExpenseDto> expenses;

  ToiEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dateMode,
    required this.dates,
    required this.guestCount,
    required this.budget,
    this.imageUrl,
    this.expenses = const [],
  });

  static const int? maxMultipleDates = null;

  DateTime get firstDate => dates.first.startDate;

  static List<ToiEvent> mockEvents = [
    ToiEvent(
      id: 'e1',
      userId: 'u-admin',
      title: 'Admin Wedding',
      description: 'A grand wedding celebration',
      dateMode: DateSelectionMode.dateRange,
      dates: [
        EventDateDto(
          startDate: DateTime(2026, 8, 20),
          endDate: DateTime(2026, 8, 22),
        ),
      ],
      guestCount: 200,
      budget: 5000000,
    ),
    ToiEvent(
      id: 'e2',
      userId: 'u-user123',
      title: 'Photo Sessions',
      description: 'Several possible days',
      dateMode: DateSelectionMode.multipleDates,
      dates: [
        EventDateDto(
          startDate: DateTime(2026, 12, 10),
          endDate: DateTime(2026, 12, 10),
        ),
        EventDateDto(
          startDate: DateTime(2026, 12, 15),
          endDate: DateTime(2026, 12, 17),
        ),
      ],
      guestCount: 50,
      budget: 300000,
      expenses: [
        ExpenseDto(id: 1, expenseType: ExpenseType.decor, amount: 450000),
        ExpenseDto(id: 2, expenseType: ExpenseType.venue, amount: 300000),
      ],
    ),
  ];
}