enum UserRole { user, vendor, admin }

enum City {
  almaty,
  astana,
  notSelected;

  static City fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ALMATY':
        return City.almaty;
      case 'ASTANA':
        return City.astana;

      default:
        return City.notSelected;
    }
  }

  String get label {
    switch (this) {
      case City.almaty:
        return 'Almaty';
      case City.astana:
        return 'Astana';
      case City.notSelected:
        return 'Not selected';
    }
  }

  String toQueryString() {
    switch (this) {
      case City.almaty:
        return 'ALMATY';
      case City.astana:
        return 'ASTANA';

      case City.notSelected:
        return 'NOT_SELECTED';
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
    city:
        json['city'] != null ? City.fromString(json['city']) : City.notSelected,
    role: UserRole.values.byName(json['role'].toString().toLowerCase()),
  );
}
