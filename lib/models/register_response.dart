class RegisterResponse {
  final String id;
  final String message;

  RegisterResponse({required this.id, required this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        id: json['id'].toString(),  // na vsyakiy sluchay konvertiruem v string
        message: json['message'],
      );
}