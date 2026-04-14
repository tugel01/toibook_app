enum WidgetType {
  guestCount,
  countdown,
  budget;

  static WidgetType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'GUEST_COUNT': return WidgetType.guestCount;
      case 'COUNTDOWN': return WidgetType.countdown;
      case 'BUDGET': return WidgetType.budget;
      default: throw Exception('Unknown widget type: $value');
    }
  }
}