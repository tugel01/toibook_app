enum ExpenseType {
  decor,
  venue,
  music,
  food,
  other;

  static ExpenseType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DECOR': return ExpenseType.decor;
      case 'VENUE': return ExpenseType.venue;
      case 'MUSIC': return ExpenseType.music;
      case 'FOOD': return ExpenseType.food;
      default: return ExpenseType.other;
    }
  }

  String get label {
    switch (this) {
      case ExpenseType.decor: return 'Decor';
      case ExpenseType.venue: return 'Venue';
      case ExpenseType.music: return 'Music';
      case ExpenseType.food: return 'Food';
      case ExpenseType.other: return 'Other';
    }
  }
}