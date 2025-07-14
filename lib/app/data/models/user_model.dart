class CompanyModel {
  final String id;
  final String name;
  final int size;
  final String? createdAt;
  final String? updatedAt;

  CompanyModel({
    required this.id,
    required this.name,
    required this.size,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id']?.toString() ?? '', // Ensure it's always a string
      name: json['name'] ?? '',
      size: json['size'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

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
  final String? companyId; // Changed from int? to String?
  final CompanyModel? company;

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
    this.companyId,
    this.company,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? fallbackRole}) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      role: json['role'] ?? fallbackRole ?? 'manager',
      token: json['token'] ?? json['access_token'] ?? '',
      phone: json['phone'],
      profilePicture: json['profile_picture'],
      companyName: json['company_name'],
      companySize: json['company_size'],
      companyId: json['company_id']?.toString(), // Ensure string conversion
      company: json['company'] != null ? CompanyModel.fromJson(json['company']) : null,
    );
  }
}
