import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toibook_app/models/event_date_dto.dart';
import 'package:toibook_app/models/event_card_response.dart';
import 'package:toibook_app/models/toi_event.dart';
import 'package:toibook_app/services/auth_service.dart';

class EventService {
  final _baseUrl = 'https://toibook.up.railway.app/api';
  final _authService = AuthService();

  Future<Map<String, String>> get _headers async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<EventCardResponse>> getEvents() async {
    print("EventService.getEvents called");
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/events'),
        headers: await _headers,
      );

      print('getEvents status: ${res.statusCode}');
      print('getEvents body: ${res.body}');

      if (res.statusCode == 200) {
        final List<dynamic> body = jsonDecode(res.body);
        return body.map((e) => EventCardResponse.fromJson(e)).toList();
      }
      if (res.statusCode == 404) return [];
      throw Exception('Failed to load events: ${res.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> createEvent({
    required String name,
    required String description,
    required DateSelectionMode dateMode,
    required List<EventDateDto> dates,
    required int guestCount,
    required double budget,
    String? coverImageUrl,
  }) async {
    try {
      final body = {
        'name': name,
        'description': description,
        'dateType': dateMode.toBackendString(),
        'dates': dates.map((d) => d.toJson()).toList(),
        'guestCount': guestCount,
        'budget': budget.toInt(),
        if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      };

      final res = await http.post(
        Uri.parse('$_baseUrl/events'),
        headers: await _headers,
        body: jsonEncode(body),
      );

      print('createEvent status: ${res.statusCode}');
      print('createEvent body: ${res.body}');

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Failed to create event: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}