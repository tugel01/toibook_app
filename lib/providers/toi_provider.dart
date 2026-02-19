import 'package:flutter/material.dart';
import 'package:toibook_app/services/auth_service.dart';
import '../models/toi_event.dart';

class ToiProvider with ChangeNotifier {
  final List<ToiEvent> _events = ToiEvent.mockEvents;

  List<ToiEvent> get events => _events;

  String? _currentCity;
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void resetOnLogout() {
    _currentCity = "Select City";       // restore default city. we dont need it actually but let it be
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  String get currentCity {
    if (_currentCity != null) return _currentCity!;

    final user = AuthService.currentUser;
    return user?.city ?? "Select City";
  }

  void updateCity(String newCity) {
    _currentCity = newCity;
    notifyListeners();
  }

  List<ToiEvent> getEventsByUserId(String userId) {
    return _events.where((e) => e.userId == userId).toList();
  }

  void addEvent(ToiEvent newEvent) {
    _events.add(newEvent);

    notifyListeners();
  }
}
