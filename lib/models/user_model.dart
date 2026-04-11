class UserModel {
  final String id;
  String fullName;
  final String email;
  final String phoneNumber;
  String city;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.city,
    this.profileImageUrl,
  });
}