import 'package:intl/intl.dart';

class ProductModel {
  final int? id;
  final String partNumber;
  final String description;
  final String location;
  final int quantity;
  final int batchNumber;
  final String expiryDate;
  final String companyId;
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
    required this.companyId,
    this.createdAt,
    this.updatedAt,
  });

  // Create ProductModel from JSON (from backend) with improved null safety
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        id: _safeParseInt(json['id']),
        partNumber: _safeParseString(json['part_number']) ?? '',
        description: _safeParseString(json['description']) ?? '',
        location: _safeParseString(json['location']) ?? '',
        quantity: _safeParseInt(json['quantity']) ?? 0,
        batchNumber: _safeParseInt(json['batch_number']) ?? 0,
        expiryDate: _safeParseDate(json['expiry_date']),
        companyId: _safeParseString(json['company_id']) ?? '',
        createdAt: _safeParseString(json['created_at'], allowNull: true),
        updatedAt: _safeParseString(json['updated_on'] ?? json['updated_at'], allowNull: true),
      );
    } catch (e) {
      print('❌ Error creating ProductModel from JSON: $e');
      print('📋 JSON data: $json');
      rethrow;
    }
  }

  // Helper method to safely parse strings
  static String? _safeParseString(dynamic value, {bool allowNull = false}) {
    if (value == null) {
      if (allowNull) return null;
      return '';
    }
    return value.toString().trim();
  }

  // Helper method to safely parse integers
  static int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  // Helper method to safely parse and validate dates
  static String _safeParseDate(dynamic value) {
    if (value == null) {
      // Return tomorrow's date as default if no date provided
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return tomorrow.toIso8601String().split('T')[0];
    }
    
    final dateStr = value.toString().trim();
    if (dateStr.isEmpty) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return tomorrow.toIso8601String().split('T')[0];
    }
    
    // Try to parse various date formats
    try {
      // ISO format (YYYY-MM-DD)
      if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(dateStr)) {
        DateTime.parse(dateStr); // Validate the date
        return dateStr.split('T')[0]; // Remove time component if present
      }
      
      // DD/MM/YYYY format
      if (RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$').hasMatch(dateStr)) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final date = DateTime(year, month, day);
          return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
      }
      
      // If we can't parse it, try DateTime.parse as last resort
      final parsed = DateTime.parse(dateStr);
      return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
      
    } catch (e) {
      print('⚠️ Warning: Could not parse date "$dateStr", using tomorrow as default');
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return tomorrow.toIso8601String().split('T')[0];
    }
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
      'company_id': companyId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  // Helper method to format expiry date for display with error handling
  String get formattedExpiryDate {
    try {
      if (expiryDate.isEmpty) return 'No date set';
      
      final dateTime = DateTime.parse(expiryDate);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (e) {
      print('⚠️ Warning: Could not format expiry date "$expiryDate"');
      return expiryDate.isNotEmpty ? expiryDate : 'Invalid date';
    }
  }

  // Helper method to check if product is expired with error handling
  bool get isExpired {
    try {
      if (expiryDate.isEmpty) return false;
      
      final dateTime = DateTime.parse(expiryDate);
      final now = DateTime.now();
      // Compare only the date part, not time
      final expiryDateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final nowDateOnly = DateTime(now.year, now.month, now.day);
      
      return expiryDateOnly.isBefore(nowDateOnly);
    } catch (e) {
      print('⚠️ Warning: Could not check expiry for date "$expiryDate"');
      return false; // Assume not expired if we can't parse the date
    }
  }

  // Helper method to check if product is expiring soon (within 7 days, but not expired)
  bool get isExpiringSoon {
    try {
      if (isExpired) return false; // Expired products are not "expiring soon"
      
      final days = daysUntilExpiry;
      return days >= 0 && days <= 7;
    } catch (e) {
      print('⚠️ Warning: Could not check expiring soon status');
      return false;
    }
  }

  // Helper method to get days until expiry with error handling
  int get daysUntilExpiry {
    try {
      if (expiryDate.isEmpty) return 999; // Large number for "no expiry"
      
      final dateTime = DateTime.parse(expiryDate);
      final now = DateTime.now();
      // Compare only the date part, not time
      final expiryDateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final nowDateOnly = DateTime(now.year, now.month, now.day);
      
      final difference = expiryDateOnly.difference(nowDateOnly);
      return difference.inDays;
    } catch (e) {
      print('⚠️ Warning: Could not calculate days until expiry for date "$expiryDate"');
      return 999; // Large number indicating unknown/far future
    }
  }

  // Helper method to format created_at for display with error handling
  String get formattedCreatedAt {
    if (createdAt == null || createdAt!.isEmpty) {
      return 'Date added: Not available';
    }

    try {
      final dateTime = DateTime.parse(createdAt!);
      final formatter = DateFormat.yMMMMd().add_jm();
      return 'Added on: ${formatter.format(dateTime)}';
    } catch (e) {
      print('⚠️ Warning: Could not format created date "$createdAt"');
      return 'Added on: ${createdAt!}';
    }
  }

  // Helper method to get expiry status with color coding info
  String get expiryStatus {
    try {
      if (isExpired) return 'EXPIRED';
      
      final days = daysUntilExpiry;
      if (days <= 7) return 'EXPIRES SOON';
      if (days <= 30) return 'EXPIRING';
      return 'GOOD';
    } catch (e) {
      return 'UNKNOWN';
    }
  }

  // Helper method to validate the model data
  bool get isValid {
    try {
      return partNumber.isNotEmpty &&
             description.isNotEmpty &&
             location.isNotEmpty &&
             quantity >= 0 &&
             batchNumber >= 0 &&
             expiryDate.isNotEmpty &&
             companyId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, partNumber: $partNumber, description: $description, quantity: $quantity, isValid: $isValid)';
  }

  // Create a copy of the product with updated fields
  ProductModel copyWith({
    int? id,
    String? partNumber,
    String? description,
    String? location,
    int? quantity,
    int? batchNumber,
    String? expiryDate,
    String? companyId,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      partNumber: partNumber ?? this.partNumber,
      description: description ?? this.description,
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}