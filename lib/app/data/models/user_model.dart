class UserModel {
  final String name;
  final String email;
  final String role;
  final String token;
  final String? phone;
  final String? profilePicture;
  final String? companyName;
  final int? companySize;
  final int? id;

  UserModel({
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    this.phone,
    this.profilePicture,
    this.companyName,
    this.companySize,
    this.id,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'manager',
      token: json['token'] ?? json['access_token'] ?? '',
      phone: json['phone'],
      profilePicture: json['profile_picture'],
      companyName: json['company_name'],
      companySize: json['company_size'],
    );
  }
}
