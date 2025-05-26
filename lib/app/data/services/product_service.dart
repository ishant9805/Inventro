import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../modules/auth/controller/auth_controller.dart';
import 'package:path/path.dart' as path;

class ProductService {
  final String baseUrl = 'https://inventro-backend.vercel.app/';

  // Helper method to get auth headers with token
  Map<String, String> getAuthHeaders() {
    final authController = Get.find<AuthController>();
    final token = authController.user.value?.token;
    
    print('🔐 Auth Debug:');
    print('  User exists: ${authController.user.value != null}');
    print('  Token exists: ${token != null}');
    print('  Token length: ${token?.length ?? 0}');
    print('  User email: ${authController.user.value?.email}');
    print('  User role: ${authController.user.value?.role}');
    
    final headers = {'Content-Type': 'application/json'};
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print('  ✅ Authorization header added');
    } else {
      print('  ❌ No valid token found!');
    }
    
    return headers;
  }

  // Helper method to safely parse JSON response
  Map<String, dynamic> _safeJsonDecode(String responseBody, int statusCode) {
    print('🔍 Response Debug:');
    print('  Status Code: $statusCode');
    print('  Body Length: ${responseBody.length}');
    print('  Body Content: "${responseBody}"');
    print('  Is Empty: ${responseBody.isEmpty}');
    
    if (responseBody.isEmpty) {
      if (statusCode >= 200 && statusCode < 300) {
        print('  ✅ Empty response but successful status - treating as success');
        return {'success': true, 'message': 'Operation completed successfully'};
      } else {
        print('  ❌ Empty response with error status');
        return {'error': true, 'message': 'Server returned empty response with status $statusCode'};
      }
    }

    // Check if response is HTML (common for server errors)
    if (responseBody.trim().toLowerCase().startsWith('<html>') || 
        responseBody.trim().toLowerCase().startsWith('<!doctype')) {
      print('  ❌ Server returned HTML instead of JSON');
      return {
        'error': true, 
        'message': 'Server error - received HTML page instead of JSON. Backend may be down or misconfigured.',
        'html_response': responseBody.substring(0, 200) // First 200 chars for debugging
      };
    }

    try {
      final decoded = jsonDecode(responseBody);
      print('  ✅ Successfully parsed JSON');
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List) {
        return {'data': decoded};
      } else {
        return {'message': decoded.toString()};
      }
    } catch (e) {
      print('  ❌ JSON parsing failed: $e');
      return {
        'error': true, 
        'message': 'Invalid response format from server', 
        'parse_error': e.toString(),
        'raw_response': responseBody.length > 500 ? responseBody.substring(0, 500) + '...' : responseBody
      };
    }
  }

  // Helper method to safely parse JSON array response
  List<Map<String, dynamic>> _safeJsonDecodeArray(String responseBody, int statusCode) {
    if (responseBody.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      } else if (decoded is Map<String, dynamic>) {
        // If single object returned, wrap in array
        return [decoded];
      } else {
        return [];
      }
    } catch (e) {
      print('JSON decode error for array: $e');
      print('Response body: $responseBody');
      return [];
    }
  }

  // ADD PRODUCT - Following backend schema
  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> productData) async {
    try {
      final endpoint = path.join(baseUrl, 'products');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
      
      // Transform data to match backend schema
      final transformedData = {
        "part_number": productData['part_number'],
        "description": productData['description'],
        "location": productData['location'],
        "quantity": productData['quantity'],
        "batch_number": int.tryParse(productData['batch_number'].toString()) ?? 0,
        "expiry_date": _formatDateForBackend(productData['expiry_date']),
      };

      print('Sending product data to: $uri');
      print('Data: ${jsonEncode(transformedData)}');
      print('Headers: ${getAuthHeaders()}');
      
      final response = await http.post(
        uri,
        headers: getAuthHeaders(),
        body: jsonEncode(transformedData),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your internet connection');
        },
      );

      print('Add Product Response Status: ${response.statusCode}');
      print('Add Product Response Body: ${response.body}');
      print('Add Product Response Headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = _safeJsonDecode(response.body, response.statusCode);
        if (responseData['error'] == true) {
          throw Exception(responseData['message'] ?? 'Failed to add product');
        }
        return responseData;
      } else {
        final errorData = _safeJsonDecode(response.body, response.statusCode);
        throw Exception(errorData['message'] ?? errorData['detail'] ?? 'Failed to add product (${response.statusCode})');
      }
    } on http.ClientException {
      throw Exception('Network connection error. Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid server response format. Please try again later.');
    } catch (e) {
      print('Add Product Error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // GET ALL PRODUCTS
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final endpoint = path.join(baseUrl, 'products');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
      
      print('Fetching products from: $uri');
      print('Headers: ${getAuthHeaders()}');
      
      final response = await http.get(
        uri,
        headers: getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your internet connection');
        },
      );

      print('Get Products Response Status: ${response.statusCode}');
      print('Get Products Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return _safeJsonDecodeArray(response.body, response.statusCode);
      } else {
        final errorData = _safeJsonDecode(response.body, response.statusCode);
        throw Exception(errorData['message'] ?? errorData['detail'] ?? 'Failed to fetch products (${response.statusCode})');
      }
    } on http.ClientException {
      throw Exception('Network connection error. Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid server response format. Please try again later.');
    } catch (e) {
      print('Get Products Error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // GET PRODUCT BY ID
  Future<Map<String, dynamic>> getProductById(int productId) async {
    try {
      final endpoint = path.join(baseUrl, 'products', productId.toString());
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
      
      final response = await http.get(
        uri,
        headers: getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your internet connection');
        },
      );

      if (response.statusCode == 200) {
        final responseData = _safeJsonDecode(response.body, response.statusCode);
        if (responseData['error'] == true) {
          throw Exception(responseData['message'] ?? 'Failed to fetch product');
        }
        return responseData;
      } else {
        final errorData = _safeJsonDecode(response.body, response.statusCode);
        throw Exception(errorData['message'] ?? errorData['detail'] ?? 'Failed to fetch product (${response.statusCode})');
      }
    } on http.ClientException {
      throw Exception('Network connection error. Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid server response format. Please try again later.');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // UPDATE PRODUCT
  Future<Map<String, dynamic>> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      final endpoint = path.join(baseUrl, 'products', productId.toString());
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
      
      // Transform data to match backend schema
      final transformedData = {
        "part_number": productData['part_number'],
        "description": productData['description'],
        "location": productData['location'],
        "quantity": productData['quantity'],
        "batch_number": int.tryParse(productData['batch_number'].toString()) ?? 0,
        "expiry_date": _formatDateForBackend(productData['expiry_date']),
      };

      final response = await http.put(
        uri,
        headers: getAuthHeaders(),
        body: jsonEncode(transformedData),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your internet connection');
        },
      );

      if (response.statusCode == 200) {
        final responseData = _safeJsonDecode(response.body, response.statusCode);
        if (responseData['error'] == true) {
          throw Exception(responseData['message'] ?? 'Failed to update product');
        }
        return responseData;
      } else {
        final errorData = _safeJsonDecode(response.body, response.statusCode);
        throw Exception(errorData['message'] ?? errorData['detail'] ?? 'Failed to update product (${response.statusCode})');
      }
    } on http.ClientException {
      throw Exception('Network connection error. Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid server response format. Please try again later.');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // DELETE PRODUCT
  Future<bool> deleteProduct(int productId) async {
    try {
      final endpoint = path.join(baseUrl, 'products', productId.toString());
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
      
      print('Deleting product from: $uri');
      print('Headers: ${getAuthHeaders()}');
      
      final response = await http.delete(
        uri,
        headers: getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your internet connection');
        },
      );

      print('Delete Product Response Status: ${response.statusCode}');
      print('Delete Product Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 202) {
        // For delete operations, empty response is often expected
        return true;
      } else {
        final errorData = _safeJsonDecode(response.body, response.statusCode);
        throw Exception(errorData['message'] ?? errorData['detail'] ?? 'Failed to delete product (${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      print('HTTP Client Error: $e');
      throw Exception('Network connection error. Please check your internet connection.');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw Exception('Invalid server response format. Please try again later.');
    } catch (e) {
      print('Delete Product Error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Helper method to format date for backend (ISO 8601 format)
  String _formatDateForBackend(String dateString) {
    try {
      // Parse date string (expected format: "dd/mm/yyyy")
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        
        final dateTime = DateTime(year, month, day);
        return dateTime.toIso8601String();
      }
      
      // If parsing fails, return current date
      return DateTime.now().toIso8601String();
    } catch (e) {
      // If any error occurs, return current date
      return DateTime.now().toIso8601String();
    }
  }

  // Helper method to format date from backend for display
  String formatDateForDisplay(String isoDateString) {
    try {
      final dateTime = DateTime.parse(isoDateString);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (e) {
      return isoDateString;
    }
  }

  // Helper method to validate backend connection and authentication
  Future<Map<String, dynamic>> testBackendConnection() async {
    try {
      final endpoint = path.join(baseUrl, 'products');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
      
      print('🔧 Testing backend connection...');
      print('  URL: $uri');
      
      final response = await http.get(
        uri,
        headers: getAuthHeaders(),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      print('🔧 Backend Test Results:');
      print('  Status: ${response.statusCode}');
      print('  Headers: ${response.headers}');
      print('  Body: ${response.body}');
      
      return {
        'status_code': response.statusCode,
        'success': response.statusCode < 400,
        'body': response.body,
        'headers': response.headers,
      };
      
    } catch (e) {
      print('🔧 Backend Test Failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}