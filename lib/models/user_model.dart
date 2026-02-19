class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String city;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.city,
    this.profileImageUrl,
  });

  // Mock data for testing your UI
  static UserModel mockUser = UserModel(
    id: 'u-001',
    fullName: 'Alisher Kanatov',
    email: 'alisher@toibook.kz',
    phoneNumber: '+7 707 123 45 67', 
    city: 'Astana',
  );
}