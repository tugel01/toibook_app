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