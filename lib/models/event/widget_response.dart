import 'package:toibook_app/models/budget/budget_response.dart';
import 'package:toibook_app/models/event/widget_type.dart';

class WidgetResponse {
  final int id;
  final WidgetType widgetType;
  final Object data;

  WidgetResponse({
    required this.id,
    required this.widgetType,
    required this.data,
  });

  factory WidgetResponse.fromJson(Map<String, dynamic> json) {
    final widgetType = WidgetType.fromString(json['widgetType']);
    final Object data;

    switch (widgetType) {
      case WidgetType.guestCount:
        data = json['data'] as int;
        break;
      case WidgetType.countdown:
        data = (json['data'] as String?) ?? '';
        break;
      case WidgetType.budget:
        data = BudgetResponse.fromJson(json['data'] as Map<String, dynamic>);
        break;
    }

    return WidgetResponse(id: json['id'], widgetType: widgetType, data: data);
  }

  int get guestCount => data as int;
  String? get countdown => (data as String).isEmpty ? null : data as String;
  BudgetResponse get budget => data as BudgetResponse;
}
