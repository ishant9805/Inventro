class UserModel {
  final String name;
  final String email;
  final String role;
  final String token;

  UserModel({
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      email: json['email'],
      role: json['role'],
      token: json['token'],
    );
  }
}
