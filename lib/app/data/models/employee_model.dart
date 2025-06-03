class EmployeeModel {
  final int? id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String phone;
  final String? profilePicture;
  final int managerId;
  final String? createdAt;
  final String? updatedAt;

  EmployeeModel({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.phone,
    this.profilePicture,
    required this.managerId,
    this.createdAt,
    this.updatedAt,
  });

  // Create EmployeeModel from JSON (from backend)
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Employee',
      department: json['department'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['profile_picture'],
      managerId: json['manager_id'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Convert EmployeeModel to JSON (for sending to backend)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'phone': phone,
      'profile_picture': profilePicture ?? '',
      'manager_id': managerId,
    };
  }

  // Create a copy with updated fields
  EmployeeModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? department,
    String? phone,
    String? profilePicture,
    int? managerId,
    String? createdAt,
    String? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      managerId: managerId ?? this.managerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
