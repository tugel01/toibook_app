import 'package:flutter/material.dart';
import 'package:toibook_app/models/expense.dart';
import 'package:toibook_app/services/auth_service.dart';
import '../models/toi_event.dart';

class ToiProvider with ChangeNotifier {
  final List<ToiEvent> _events = ToiEvent.mockEvents;

  List<ToiEvent> get events => _events;

  String? _currentCity;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void resetOnLogout() {
    _currentCity = 'Select City';
    notifyListeners();
  }

  String get currentCity {
    if (_currentCity != null) return _currentCity!;
    final user = AuthService.currentUser;
    return user.city ?? 'Select City';
  }

  void updateCity(String newCity) {
    _currentCity = newCity;
    notifyListeners();
  }

  void updateUserName(String newName) {
    AuthService.currentUser.fullName = newName;
    notifyListeners();
  }

  void addEvent(ToiEvent newEvent) {
    _events.add(newEvent);
    notifyListeners();
  }

  void addExpense(String eventId, Expense expense) {
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
      expenses: [...event.expenses, expense],
    );
    notifyListeners();
  }

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

  void updateBudget(String eventId, double newBudget) {
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
      expenses: event.expenses,
    );
    notifyListeners();
  }
}