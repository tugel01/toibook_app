import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toibook_app/models/event/dashboard_response.dart';
import 'package:toibook_app/models/event/date_selection_mode.dart';
import 'package:toibook_app/models/event/event_card_response.dart';
import 'package:toibook_app/models/event/event_date_dto.dart';
import 'package:toibook_app/models/event/event_response.dart';
import 'package:toibook_app/models/budget/expense_dto.dart';
import 'package:toibook_app/models/user_model.dart';
import 'package:toibook_app/services/auth_service.dart';
import 'package:toibook_app/services/event_service.dart';

class ToiProvider with ChangeNotifier {
  final _eventService = EventService();

  List<EventCardResponse> _eventCards = [];
  bool _isLoadingEvents = false;
  String? _eventsError;

  List<EventCardResponse> get eventCards => _eventCards;
  bool get isLoadingEvents => _isLoadingEvents;
  String? get eventsError => _eventsError;

  DashboardResponse? _dashboard;
  bool _isLoadingDashboard = false;
  String? _dashboardError;

  DashboardResponse? get dashboard => _dashboard;
  bool get isLoadingDashboard => _isLoadingDashboard;
  String? get dashboardError => _dashboardError;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  Future<void> loadUserProfile({bool force = false}) async {
    if (_userProfile != null && !force) return;
    _userProfile = await AuthService().fetchUserProfile();
    notifyListeners();
  }

  void clearUserProfile() {
    _userProfile = null;
    notifyListeners();
  }

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  final _storage = const FlutterSecureStorage();

  Future<void> loadTheme() async {
    final saved = await _storage.read(key: 'isDarkMode');
    if (saved != null) {
      _isDarkMode = saved == 'true';
      notifyListeners();
    }
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storage.write(key: 'isDarkMode', value: _isDarkMode.toString());
  }

  Future<void> loadEvents() async {
    _isLoadingEvents = true;
    _eventsError = null;
    notifyListeners();

    try {
      _eventCards = await _eventService.getEvents();
    } catch (e) {
      _eventsError = e.toString();
    } finally {
      _isLoadingEvents = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadEvents();

  Future<void> loadDashboard(int eventId) async {
    _isLoadingDashboard = true;
    _dashboardError = null;
    _dashboard = null;
    notifyListeners();

    try {
      _dashboard = await _eventService.getDashboard(eventId);
    } catch (e) {
      _dashboardError = e.toString();
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }
  Future<EventResponse> createEvent({
    required String name,
    required String description,
    required DateSelectionMode dateType,
    required List<EventDateDto> dates,
    required int guestCount,
    required double budget,
  }) async {
    return _eventService.createEvent(
      name: name,
      description: description,
      dateMode: dateType,
      dates: dates,
      guestCount: guestCount,
      budget: budget,
    );
  }

  Future<EventResponse> uploadCoverImage({
    required int eventId,
    required File imageFile,
  }) async {
    return _eventService.uploadCoverImage(
      eventId: eventId,
      imageFile: imageFile,
    );
  }

  Future<void> addExpenseAndRefresh(int eventId, ExpenseDto expense) async {
    await _eventService.addExpense(eventId, expense);
    await updateDashboard(eventId);
  }

  Future<void> editExpense(int eventId, ExpenseDto expense) async {
    await _eventService.editExpense(eventId, expense);
    await updateDashboard(eventId);
  }

  Future<void> deleteExpense(int eventId, ExpenseDto expense) async {
    await _eventService.deleteExpense(eventId, expense);
    await updateDashboard(eventId);
  }

  Future<void> updateDashboard(int eventId) async {
    try {
      _dashboard = await _eventService.getDashboard(eventId);
    } catch (e) {
      _dashboardError = e.toString();
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  
}