import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toibook_app/models/dashboard_response.dart';
import 'package:toibook_app/models/date_selection_mode.dart';
import 'package:toibook_app/models/event_date_dto.dart';
import 'package:toibook_app/models/event_card_response.dart';
import 'package:toibook_app/models/expense_dto.dart';
import 'package:toibook_app/services/auth_service.dart';

class EventService {
  final _baseUrl = 'https://toibook.up.railway.app/api';
  final _authService = AuthService();

  Future<Map<String, String>> get _headers async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future<List<EventCardResponse>> getEvents() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/events'),
        headers: await _headers,
      );

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

  Future<DashboardResponse> getDashboard(int eventId) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/events/$eventId/dashboard'),
        headers: await _headers,
      );

      if (res.statusCode == 200) {
        return DashboardResponse.fromJson(jsonDecode(res.body));
      }
      throw Exception('Failed to load dashboard: ${res.statusCode}');
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

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Failed to create event: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> addExpense(int eventId, ExpenseDto expense) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/events/$eventId/dashboard/budget/expenses'),
        headers: await _headers,
        body: jsonEncode(expense.toJson()),
      );

      if (res.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      }
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Failed to add expense: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> editExpense(int eventId, ExpenseDto expense) async {
    try {
      final res = await http.put(
        Uri.parse(
          '$_baseUrl/events/$eventId/dashboard/budget/expenses/${expense.id}',
        ),
        headers: await _headers,
        body: jsonEncode(expense.toJson()),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Failed to edit expense: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteExpense(int eventId, ExpenseDto expense) async {
    try {
      final res = await http.delete(
        Uri.parse(
          '$_baseUrl/events/$eventId/dashboard/budget/expenses/${expense.id}',
        ),
        headers: await _headers,
      );

      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception('Failed to delete expense: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
