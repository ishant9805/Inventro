import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../modules/auth/controller/auth_controller.dart';
import 'package:path/path.dart' as path;
import '../services/auth_service.dart';

class ProductService {
  final String baseUrl = 'https://backend.tecsohub.com/';
  final AuthService _authService = AuthService();

  // Enhanced helper method to get auth headers with CONSERVATIVE validation
  Future<Map<String, String>> getAuthHeaders() async {
    final authController = Get.find<AuthController>();
    final tokenValue = authController.user.value?.token;

    if (tokenValue == null || tokenValue.isEmpty) {
      throw Exception('No authentication token found. Please login again.');
    }

    final token = tokenValue.trim(); // Trim whitespace
    if (token.isEmpty) {
      throw Exception('Authentication token is empty after trimming. Please login again.');
    }

    // Only validate token for older tokens to prevent immediate post-login issues
    final tokenAgeMinutes = (await _authService.getTokenAgeInSeconds()) / 60;
    if (tokenAgeMinutes >= 5) {
      // Only validate tokens older than 5 minutes to avoid race conditions
      final isValid = await _authService.validateTokenForRequest();
      if (!isValid) {
        throw Exception('Authentication failed. Please login again.');
      }
    } else {
      print('🔄 ProductService: Using fresh token without validation (${tokenAgeMinutes.toStringAsFixed(1)} min old)');
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    
    return headers;
  }

  // Enhanced helper method to safely parse JSON response with better error handling
  Map<String, dynamic> _safeJsonDecode(String responseBody, int statusCode) {
    if (responseBody.isEmpty) {
      if (statusCode >= 200 && statusCode < 300) {
        return {'success': true, 'message': 'Operation completed successfully'};
      } else {
        return {
          'error': true,
          'message': 'Server returned empty response with status $statusCode',
        };
      }
    }

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List) {
        return {'data': decoded};
      } else {
        return {'message': decoded.toString()};
      }
    } catch (e) {
      return {
        'error': true,
        'message': 'Invalid response format from server',
        'parse_error': e.toString(),
        'raw_response': responseBody.length > 500 ? '${responseBody.substring(0, 500)}...' : responseBody,
      };
    }
  }

  // Enhanced helper method to safely parse JSON array response
  List<Map<String, dynamic>> _safeJsonDecodeArray(String responseBody, int statusCode) {
    if (responseBody.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      } else if (decoded is Map<String, dynamic>) {
        return [decoded];
      } else {
        return [];
      }
    } catch (e) {
      print('❌ JSON Parse Error for array: $e');
      print('📄 Raw response: ${responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody}');
      return [];
    }
  }

  /// Enhanced method to handle HTTP errors with specific status codes
  Exception _handleHttpError(http.Response response, String operation) {
    final statusCode = response.statusCode;
    
    try {
      final errorData = _safeJsonDecode(response.body, statusCode);
      final errorMessage = errorData['message'] ?? errorData['detail'] ?? errorData['error'];
      
      switch (statusCode) {
        case 401:
          // Token expired or invalid - trigger logout
          _authService.handleAuthError();
          return Exception('Authentication failed. Please login again.');
        case 403:
          return Exception('Access denied. You don\'t have permission to perform this action.');
        case 404:
          return Exception('Resource not found. The requested item may have been deleted.');
        case 422:
          return Exception(errorMessage ?? 'Invalid data provided. Please check your inputs.');
        case 429:
          return Exception('Too many requests. Please wait a moment and try again.');
        case 500:
          return Exception('Server error. Please try again later.');
        case 502:
        case 503:
        case 504:
          return Exception('Server temporarily unavailable. Please try again later.');
        default:
          return Exception(errorMessage ?? 'Failed to $operation (HTTP $statusCode)');
      }
    } catch (e) {
      return Exception('Server error: HTTP $statusCode');
    }
  }

  // ADD PRODUCT - Enhanced with better error handling
  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> productData) async {
    try {
      final endpoint = path.join(baseUrl, 'products/');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      print('🔄 ProductService: Adding product with data: $productData');

      // Get manager's company ID from auth controller
      final authController = Get.find<AuthController>();
      final managerCompanyId = authController.user.value?.companyId ??
          authController.user.value?.company?.id;

      if (managerCompanyId == null) {
        throw Exception('Manager company ID not found. Please login again.');
      }

      // Capture local date-time
      final createdAt = DateTime.now().toIso8601String();

      // Create payload matching your requirements
      final payload = {
        "part_number": productData['part_number'],
        "description": productData['description'],
        "location": productData['location'],
        "quantity": productData['quantity'],
        "batch_number": productData['batch_number'],
        "expiry_date": productData['expiry_date'], // Expected format: "YYYY-MM-DD"
        "company_id": managerCompanyId,
        "created_at": createdAt,
      };

      final authHeaders = await getAuthHeaders();
      final requestHeaders = {
        ...authHeaders,
        'Content-Type': 'application/json',
      };

      final response = await http
          .post(
            uri,
            headers: requestHeaders,
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please check your internet connection');
            },
          );

      print('📊 ProductService: Add response - ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = _safeJsonDecode(response.body, response.statusCode);
        if (responseData['error'] == true) {
          throw Exception(responseData['message'] ?? 'Failed to add product');
        }
        return responseData;
      } else {
        throw _handleHttpError(response, 'add product');
      }
    } on http.ClientException {
      print('❌ ProductService: Network Error');
      throw Exception('Network connection error. Please check your internet connection.');
    } on FormatException {
      print('❌ ProductService: JSON Parse Error');
      throw Exception('Invalid server response format. Please try again later.');
    } catch (e) {
      print('❌ ProductService: Unexpected Error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // GET ALL PRODUCTS - Enhanced with better error handling
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      print('🔄 ProductService: Starting product fetch...');

      // Use enhanced auth headers method
      final authHeaders = await getAuthHeaders();
      print('✅ ProductService: Token validated and retrieved');

      final endpoint = path.join(baseUrl, 'products/');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
      print('🌐 ProductService: Endpoint: $uri');

      final requestHeaders = {
        ...authHeaders,
        'Content-Type': 'application/json',
      };

      final response = await http
          .get(
            uri,
            headers: requestHeaders,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please check your internet connection');
            },
          );

      print('📊 ProductService: Response Status: ${response.statusCode}');
      print('📄 ProductService: Response Headers: ${response.headers}');
      print('📝 ProductService: Response Body (first 500 chars): ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}');

      if (response.statusCode == 200) {
        final products = _safeJsonDecodeArray(response.body, response.statusCode);
        print('✅ ProductService: Successfully parsed ${products.length} products');
        return products;
      } else {
        throw _handleHttpError(response, 'fetch products');
      }
    } on http.ClientException {
      print('❌ ProductService: Network Error');
      throw Exception('Network connection error. Please check your internet connection.');
    } on FormatException {
      print('❌ ProductService: JSON Parse Error');
      throw Exception('Invalid server response format. Please try again later.');
    } catch (e) {
      print('❌ ProductService: Unexpected Error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // GET PRODUCT BY ID - Enhanced with better error handling
  Future<Map<String, dynamic>> getProductById(int productId) async {
    try {
      final endpoint = path.join(baseUrl, 'products', productId.toString());
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      final authHeaders = await getAuthHeaders();
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(
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
        throw _handleHttpError(response, 'fetch product');
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

  // UPDATE PRODUCT - Enhanced with better error handling
  Future<Map<String, dynamic>> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      final endpoint = path.join(baseUrl, 'products', productId.toString());
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      print('🔄 ProductService: Updating product $productId with data: $productData');

      // Transform data to match backend schema
      final transformedData = {
        "part_number": productData['part_number'],
        "description": productData['description'],
        "location": productData['location'],
        "quantity": productData['quantity'],
        "batch_number": productData['batch_number'],
        "expiry_date": productData['expiry_date'],
      };

      print('🔄 ProductService: Transformed data for backend: $transformedData');

      final authHeaders = await getAuthHeaders();
      final requestHeaders = {
        ...authHeaders,
        'Content-Type': 'application/json',
      };

      final response = await http
          .put(
            uri,
            headers: requestHeaders,
            body: jsonEncode(transformedData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please check your internet connection');
            },
          );

      print('📊 ProductService: Update response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = _safeJsonDecode(response.body, response.statusCode);
        if (responseData['error'] == true) {
          throw Exception(responseData['message'] ?? 'Failed to update product');
        }
        print('✅ ProductService: Product updated successfully');
        return responseData;
      } else {
        throw _handleHttpError(response, 'update product');
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

  // DELETE PRODUCT - Enhanced with better error handling
  Future<bool> deleteProduct(int productId) async {
    try {
      final endpoint = path.join(baseUrl, 'products', productId.toString());
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      final authHeaders = await getAuthHeaders();
      final response = await http
          .delete(uri, headers: authHeaders)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please check your internet connection');
            },
          );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 202) {
        return true;
      } else {
        throw _handleHttpError(response, 'delete product');
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
      final endpoint = path.join(baseUrl, 'products/');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      final authHeaders = await getAuthHeaders();
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      return {
        'status_code': response.statusCode,
        'success': response.statusCode < 400,
        'body': response.body,
        'headers': response.headers,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}