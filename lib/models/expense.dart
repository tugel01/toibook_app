enum ExpenseCategory { decor, venue, music, food, other }

extension ExpenseCategoryLabel on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.decor: return 'Decor';
      case ExpenseCategory.venue: return 'Venue';
      case ExpenseCategory.music: return 'Music';
      case ExpenseCategory.food: return 'Food';
      case ExpenseCategory.other: return 'Other';
    }
  }
}

class Expense {
  final String id;
  final ExpenseCategory category;
  final double amount;
  final String? note;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    this.note,
  });
}