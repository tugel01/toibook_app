enum UserRole { USER, VENDOR, ADMIN }

enum City {
  ALMATY,
  ASTANA,
  NOT_SELECTED;

  static City fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ALMATY':
        return City.ALMATY;
      case 'ASTANA':
        return City.ASTANA;
      case 'NOT_SELECTED':
        return City.NOT_SELECTED;
      default:
        return City.ALMATY;
    }
  }

  String get label {
    switch (this) {
      case City.ALMATY:
        return 'Almaty';
      case City.ASTANA:
        return 'Astana';
      case City.NOT_SELECTED:
        return 'Not selected';
    }
  }
}

class UserProfile {
  final int id;
  final String name;
  final String surname;
  final String email;
  final City? city;
  final UserRole role;

  UserProfile({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.city,
    required this.role,
  });
  String get fullname => '$name $surname';

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    surname: json['surname'],
    email: json['email'],
    city: json['city'] != null ? City.values.byName(json['city']) : City.NOT_SELECTED,
    role: UserRole.values.byName(json['role']),
  );
}
