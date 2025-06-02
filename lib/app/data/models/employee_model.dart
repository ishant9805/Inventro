class EmployeeModel {
  final int? id;
  final String name;
  final String email;
  final String pin;
  final String role;
  final String department;
  final int managerId;
  final String? createdAt;
  final String? updatedAt;

  EmployeeModel({
    this.id,
    required this.name,
    required this.email,
    required this.pin,
    required this.role,
    required this.department,
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
      pin: json['pin'] ?? '',
      role: json['role'] ?? 'Employee',
      department: json['department'] ?? '',
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
      'pin': pin,
      'role': role,
      'department': department,
      'manager_id': managerId,
    };
  }

  // Create a copy with updated fields
  EmployeeModel copyWith({
    int? id,
    String? name,
    String? email,
    String? pin,
    String? role,
    String? department,
    int? managerId,
    String? createdAt,
    String? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      pin: pin ?? this.pin,
      role: role ?? this.role,
      department: department ?? this.department,
      managerId: managerId ?? this.managerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
