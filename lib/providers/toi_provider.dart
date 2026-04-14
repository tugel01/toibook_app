import 'package:flutter/material.dart';
import 'package:toibook_app/models/dashboard_response.dart';
import 'package:toibook_app/models/event_card_response.dart';
import 'package:toibook_app/models/event_date_dto.dart';
import 'package:toibook_app/models/expense_dto.dart';
import 'package:toibook_app/services/auth_service.dart';
import 'package:toibook_app/services/event_service.dart';
import '../models/toi_event.dart';

class ToiProvider with ChangeNotifier {
  // Backend events (home tab)
  List<EventCardResponse> _eventCards = [];
  bool _isLoadingEvents = false;
  String? _eventsError;

  List<EventCardResponse> get eventCards => _eventCards;
  bool get isLoadingEvents => _isLoadingEvents;
  String? get eventsError => _eventsError;

  // Dashboard
  DashboardResponse? _dashboard;
  bool _isLoadingDashboard = false;
  String? _dashboardError;

  DashboardResponse? get dashboard => _dashboard;
  bool get isLoadingDashboard => _isLoadingDashboard;
  String? get dashboardError => _dashboardError;

  // Local full events (mock, until fully replaced)
  final List<ToiEvent> _events = ToiEvent.mockEvents;
  List<ToiEvent> get events => _events;

  // City + theme
  String? _currentCity;
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void resetOnLogout() {
    _currentCity = 'Select City';
    _eventCards = [];
    _eventsError = null;
    _dashboard = null;
    _dashboardError = null;
    notifyListeners();
  }

  String get currentCity {
    if (_currentCity != null) return _currentCity!;
    return AuthService.currentUser.city ?? 'Select City';
  }

  void updateCity(String newCity) {
    _currentCity = newCity;
    notifyListeners();
  }

  void updateUserName(String newName) {
    AuthService.currentUser.fullName = newName;
    notifyListeners();
  }

  // Load events from backend
  Future<void> loadEvents() async {
    _isLoadingEvents = true;
    _eventsError = null;
    notifyListeners();

    try {
      _eventCards = await EventService().getEvents();
    } catch (e) {
      _eventsError = e.toString();
    } finally {
      _isLoadingEvents = false;
      notifyListeners();
    }
  }

  // Load dashboard for a specific event
  Future<void> loadDashboard(int eventId) async {
    _isLoadingDashboard = true;
    _dashboardError = null;
    _dashboard = null;
    notifyListeners();

    try {
      _dashboard = await EventService().getDashboard(eventId);
    } catch (e) {
      _dashboardError = e.toString();
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  Future<void> createAndRefresh({
    required String name,
    required String description,
    required DateSelectionMode dateMode,
    required List<EventDateDto> dates,
    required int guestCount,
    required double budget,
    String? coverImageUrl,
  }) async {
    await EventService().createEvent(
      name: name,
      description: description,
      dateMode: dateMode,
      dates: dates,
      guestCount: guestCount,
      budget: budget,
      coverImageUrl: coverImageUrl,
    );
    await loadEvents();
  }

  Future<void> addExpenseAndRefresh(int eventId, ExpenseDto expense) async {
    await EventService().addExpense(eventId, expense);
    await loadDashboard(eventId);
  }
/*
  void deleteExpense(String eventId, String expenseId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;
    final event = _events[index];
    _events[index] = ToiEvent(
      id: event.id,
      userId: event.userId,
      title: event.title,
      description: event.description,
      dateMode: event.dateMode,
      dates: event.dates,
      guestCount: event.guestCount,
      budget: event.budget,
      imageUrl: event.imageUrl,
      expenses: event.expenses.where((e) => e.id != expenseId).toList(),
    );
    notifyListeners();
  }

  */

  void updateBudgetAndExpenses(
      String eventId, double newBudget, List<ExpenseDto> updatedExpenses) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;
    final event = _events[index];
    _events[index] = ToiEvent(
      id: event.id,
      userId: event.userId,
      title: event.title,
      description: event.description,
      dateMode: event.dateMode,
      dates: event.dates,
      guestCount: event.guestCount,
      budget: newBudget,
      imageUrl: event.imageUrl,
      expenses: updatedExpenses,
    );
    notifyListeners();
  }
}