import 'package:intl/intl.dart';

class ProductModel {
  final int? id;
  final String partNumber;
  final String description;
  final String location;
  final int quantity;
  final int batchNumber;
  final String expiryDate;
  final int? companyId;
  final String? createdAt;
  final String? updatedAt;

  ProductModel({
    this.id,
    required this.partNumber,
    required this.description,
    required this.location,
    required this.quantity,
    required this.batchNumber,
    required this.expiryDate,
    this.companyId,
    this.createdAt,
    this.updatedAt,
  });

  // Create ProductModel from JSON (from backend)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      partNumber: json['part_number'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      quantity: json['quantity'] ?? 0,
      batchNumber: json['batch_number'] ?? 0,
      expiryDate: json['expiry_date'] ?? '',
      companyId: json['company_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_on'] ?? json['updated_at'],
    );
  }

  // Convert ProductModel to JSON (for backend)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'part_number': partNumber,
      'description': description,
      'location': location,
      'quantity': quantity,
      'batch_number': batchNumber,
      'expiry_date': expiryDate,
      if (companyId != null) 'company_id': companyId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  // Helper method to format expiry date for display
  String get formattedExpiryDate {
    try {
      final dateTime = DateTime.parse(expiryDate);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (e) {
      return expiryDate;
    }
  }

  // Helper method to check if product is expired
  bool get isExpired {
    try {
      final dateTime = DateTime.parse(expiryDate);
      return dateTime.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // Helper method to get days until expiry
  int get daysUntilExpiry {
    try {
      final dateTime = DateTime.parse(expiryDate);
      final difference = dateTime.difference(DateTime.now());
      return difference.inDays;
    } catch (e) {
      return 0;
    }
  }

  // Helper method to format created_at for display
  String get formattedCreatedAt {
    if (createdAt == null) return 'Date added: Not available';

    try {
      final dateTime = DateTime.parse(createdAt!);
      final formatter = DateFormat.yMMMMd().add_jm();
      return 'Added on: ${formatter.format(dateTime)}';
    } catch (e) {
      return 'Added on: ${createdAt!}';
    }
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, partNumber: $partNumber, description: $description, quantity: $quantity)';
  }
}