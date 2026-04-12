import 'package:toibook_app/models/expense.dart';

enum DateSelectionMode { single, range, multiple }

class ToiEvent {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateSelectionMode dateMode;
  final DateTime? singleDate;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final List<DateTime>? multipleDates;
  final String? location;
  final int guestCount;
  final double budget;
  final String? imageUrl;
  final List<Expense> expenses;

  ToiEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dateMode,
    this.singleDate,
    this.rangeStart,
    this.rangeEnd,
    this.multipleDates,
    this.location,
    required this.guestCount,
    required this.budget,
    this.imageUrl,
    this.expenses = const [],
  });

  // may change later if we want to enforce a limit on multiple dates
  static const int? maxMultipleDates = null;

  static List<ToiEvent> mockEvents = [
    ToiEvent(
      id: 'e1',
      userId: 'u-admin',
      title: 'Admin Wedding',
      description: 'A grand wedding celebration',
      dateMode: DateSelectionMode.single,
      singleDate: DateTime(2026, 8, 20),
      location: 'Astana',
      guestCount: 200,
      budget: 5000000,
        expenses: [
    Expense(id: 'ex1', category: ExpenseCategory.decor, amount: 450000),
    Expense(id: 'ex2', category: ExpenseCategory.venue, amount: 300000),
  ],
    ),
    ToiEvent(
      id: 'e2',
      userId: 'u-user123',
      title: 'Sanzhar Birthday',
      description: 'Birthday party',
      dateMode: DateSelectionMode.range,
      rangeStart: DateTime(2026, 12, 10),
      rangeEnd: DateTime(2026, 12, 12),
      location: 'Almaty',
      guestCount: 50,
      budget: 300000,
        expenses: [
    Expense(id: 'ex1', category: ExpenseCategory.decor, amount: 450000),
    Expense(id: 'ex2', category: ExpenseCategory.venue, amount: 300000),
  ],
    ),
  ];
}