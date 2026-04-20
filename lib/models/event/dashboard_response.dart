import 'package:toibook_app/models/event/widget_response.dart';
import 'package:toibook_app/models/event/widget_type.dart';

class DashboardResponse {
  final int eventId;
  final String name;
  final String description;
  final List<WidgetResponse> widgetResponses;
  final String? coverImageUrl;

  DashboardResponse({
    required this.eventId,
    required this.name,
    required this.description,
    required this.widgetResponses,
    this.coverImageUrl,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) =>
      DashboardResponse(
        eventId: json['eventId'],
        name: json['name'],
        description: json['description'],
        widgetResponses:
            (json['widgetResponses'] as List)
                .map((w) => WidgetResponse.fromJson(w))
                .toList(),
        coverImageUrl: json['coverImageUrl'],
      );

  WidgetResponse? get guestCountWidget =>
      widgetResponses
          .where((w) => w.widgetType == WidgetType.guestCount)
          .firstOrNull;

  WidgetResponse? get countdownWidget =>
      widgetResponses
          .where((w) => w.widgetType == WidgetType.countdown)
          .firstOrNull;

  WidgetResponse? get budgetWidget =>
      widgetResponses
          .where((w) => w.widgetType == WidgetType.budget)
          .firstOrNull;
}
