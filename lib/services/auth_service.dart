import 'package:toibook_app/models/user_model.dart';

class AuthService {
  static UserModel? currentUser;

  static final List<Map<String, String>> _mockDatabase = [
    {
      'id': 'u-admin',
      'email': 'admin@toibook.kz',
      'password': '123',
      'name': 'Alibi',
      'surname': 'Admin',
      'city': 'Almaty', // kept because current login/user model still expects it
      'phone': '',      // kept because current login/user model still expects it
    },
  ];

  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      final userRecord = _mockDatabase.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
      );

      final fullName =
          '${userRecord['name'] ?? ''} ${userRecord['surname'] ?? ''}'.trim();

      currentUser = UserModel(
        id: userRecord['id']!,
        fullName: fullName,
        email: userRecord['email']!,
        phoneNumber: userRecord['phone'] ?? '',
        city: userRecord['city'] ?? '',
      );

      return currentUser;
    } catch (e) {
      return null;
    }
  }

  Future<bool> register(
    String name,
    String surname,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    _mockDatabase.add({
      'id': email, // temporary
      'name': name,
      'surname': surname,
      'email': email,
      'password': password,
      'phone': '',
      'city': '',
    });

    print('ADDED USER: $name $surname, $email');
    print(_mockDatabase);

    return true;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    currentUser = null;
  }
}