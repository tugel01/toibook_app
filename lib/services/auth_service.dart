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
      'city': 'Almaty',
      'phone': '',
    },
  ];

  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      final userRecord = _mockDatabase.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
      );

      currentUser = _mapToUserModel(userRecord);
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

    final alreadyExists = _mockDatabase.any((u) => u['email'] == email);
    if (alreadyExists) return false;

    final newUserMap = {
      'id': 'u-${DateTime.now().millisecondsSinceEpoch}', // temporary id
      'name': name,
      'surname': surname,
      'email': email,
      'password': password,
      'phone': '',
      'city': '',
    };

    _mockDatabase.add(newUserMap);

    print('ADDED USER: $name $surname, $email');
    print(_mockDatabase);

    return true;
  }

  // helper to convert map to user model, since we are using maps as mock database records
  UserModel _mapToUserModel(Map<String, String> map) {
    return UserModel(
      id: map['id']!,
      fullName: '${map['name'] ?? ''} ${map['surname'] ?? ''}'.trim(),
      email: map['email']!,
      phoneNumber: map['phone'] ?? '',
      city: map['city'] ?? '',
    );
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    currentUser = null;
  }
}