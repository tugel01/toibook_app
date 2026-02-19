import 'package:toibook_app/models/user_model.dart';

class AuthService {
  static UserModel? currentUser; 

  static final List<Map<String, String>> _mockDatabase = [
    {
      'id': 'u-admin',
      'email': 'admin@toibook.kz',
      'password': '123',
      'name': 'Alibi Admin',
      'phone': '+7 777 000 11 22',
      'city': 'Almaty',
    },
  ];

  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final userRecord = _mockDatabase.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
      );
      

      currentUser = UserModel(
        id: userRecord['id']!,
        fullName: userRecord['name']!,
        email: userRecord['email']!,
        phoneNumber: userRecord['phone']!,
        city: userRecord['city']!,
      );
      
      return currentUser;
    } catch (e) {
      return null;
    }
  }

  Future<bool> register(String name, String email, String phone, String password, String city) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockDatabase.add({
      'name': name, 'email': email, 'phone': phone, 'password': password, 'city': city
    });
    return true;
  }
}