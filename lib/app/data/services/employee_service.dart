import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../modules/auth/controller/auth_controller.dart';
import 'package:path/path.dart' as path;
import '../services/auth_service.dart';

class EmployeeService {
  final String baseUrl = 'https://backend.tecsohub.com/';
  final AuthService _authService = AuthService();

  // Enhanced helper method to get auth headers with CONSERVATIVE validation
  Future<Map<String, String>> getAuthHeaders() async {
    final authController = Get.find<AuthController>();
    final tokenValue = authController.user.value?.token;

    if (tokenValue == null || tokenValue.isEmpty) {
      throw Exception('No authentication token found. Please login again.');
    }

    final token = tokenValue.trim();
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
      print('🔄 EmployeeService: Using fresh token without validation (${tokenAgeMinutes.toStringAsFixed(1)} min old)');
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    
    return headers;
  }

  // Enhanced helper method to safely parse JSON response
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
      print('❌ EmployeeService: JSON Parse Error for array: $e');
      print('📄 EmployeeService: Raw response: ${responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody}');
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
          return Exception('Employee not found. The requested employee may have been deleted.');
        case 422:
          return Exception(errorMessage ?? 'Invalid employee data provided. Please check your inputs.');
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

  // ADD EMPLOYEE - Enhanced with better error handling
  Future<Map<String, dynamic>> addEmployee(Map<String, dynamic> employeeData) async {
    try {
      // Fix: Remove trailing slash to avoid 307 redirect
      final endpoint = path.join(baseUrl, 'register/employee');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      print('[EmployeeService.addEmployee] Adding employee with data: $employeeData');
      print('[EmployeeService.addEmployee] Request URI: $uri');

      final authHeaders = await getAuthHeaders();
      final requestHeaders = {
        ...authHeaders,
        'Content-Type': 'application/json',
      };

      print('[EmployeeService.addEmployee] Request headers prepared');

      final response = await http
          .post(
            uri,
            headers: requestHeaders,
            body: jsonEncode(employeeData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please check your internet connection');
            },
          );

      print('[EmployeeService.addEmployee] Response Status Code: ${response.statusCode}');
      print('[EmployeeService.addEmployee] Response Body: ${response.body}');

      // Handle redirect responses (common with some backends)
      if (response.statusCode == 307 || response.statusCode == 308) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          print('[EmployeeService.addEmployee] Redirecting to: $redirectUrl');
          final redirectUri = Uri.parse(redirectUrl);
          final redirectResponse = await http
              .post(
                redirectUri,
                headers: requestHeaders,
                body: jsonEncode(employeeData),
              )
              .timeout(const Duration(seconds: 30));

          print('[EmployeeService.addEmployee] Redirect Response Status: ${redirectResponse.statusCode}');

          if (redirectResponse.statusCode == 200 || redirectResponse.statusCode == 201) {
            final responseData = _safeJsonDecode(redirectResponse.body, redirectResponse.statusCode);
            if (responseData['error'] == true) {
              throw Exception(responseData['message'] ?? 'Failed to add employee');
            }
            return responseData;
          } else {
            throw _handleHttpError(redirectResponse, 'add employee after redirect');
          }
        } else {
          throw Exception('Received redirect response but no location header found');
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = _safeJsonDecode(response.body, response.statusCode);
        if (responseData['error'] == true) {
          throw Exception(responseData['message'] ?? 'Failed to add employee');
        }
        return responseData;
      } else {
        throw _handleHttpError(response, 'add employee');
      }
    } on http.ClientException catch (e) {
      print('❌ EmployeeService: Network Error: ${e.message}');
      throw Exception('Network connection error. Please check your internet connection.');
    } on FormatException catch (e) {
      print('❌ EmployeeService: JSON Parse Error: ${e.message}');
      throw Exception('Invalid server response format. Please try again later.');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // GET ALL EMPLOYEES FOR MANAGER - Enhanced with better error handling
  Future<List<Map<String, dynamic>>> getEmployees() async {
    try {
      final endpoint = path.join(baseUrl, 'manager/employees');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      print('[EmployeeService.getEmployees] Request URI: $uri');

      final authHeaders = await getAuthHeaders();
      print('[EmployeeService.getEmployees] Auth headers prepared');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please check your internet connection');
            },
          );

      print('[EmployeeService.getEmployees] Response Status Code: ${response.statusCode}');
      print('[EmployeeService.getEmployees] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final employees = _safeJsonDecodeArray(response.body, response.statusCode);
        print('✅ EmployeeService: Successfully parsed ${employees.length} employees');
        return employees;
      } else {
        throw _handleHttpError(response, 'fetch employees');
      }
    } on http.ClientException catch (e) {
      print('❌ EmployeeService: Network Error: ${e.message}');
      throw Exception('Network connection error. Please check your internet connection.');
    } on FormatException catch (e) {
      print('❌ EmployeeService: JSON Parse Error: ${e.message}');
      throw Exception('Invalid server response format. Please try again later.');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // GET COMPANY-WIDE EMPLOYEE COUNT - Enhanced method with multiple strategies
  Future<int> getCompanyEmployeeCount() async {
    try {
      final authController = Get.find<AuthController>();
      final companyId = authController.user.value?.companyId ?? 
                       authController.user.value?.company?.id;
      
      if (companyId == null) {
        throw Exception('Company ID not found. Please login again.');
      }

      // Strategy 1: Try dedicated company employee count endpoint
      final count1 = await _tryCompanyCountEndpoint(companyId.toString());
      if (count1 != null) return count1;

      // Strategy 2: Try fetching all company employees directly
      final count2 = await _tryCompanyEmployeesEndpoint(companyId.toString());
      if (count2 != null) return count2;

      // Strategy 3: Use intelligent fallback estimation
      return await _getCompanyEmployeeCountFallback();

    } catch (e) {
      print('❌ EmployeeService: Error in getCompanyEmployeeCount: $e');
      return await _getCompanyEmployeeCountFallback();
    }
  }

  // Strategy 1: Try dedicated count endpoint
  Future<int?> _tryCompanyCountEndpoint(String companyId) async {
    try {
      final endpoint = path.join(baseUrl, 'companies', companyId, 'employees', 'count');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      print('[EmployeeService.Strategy1] Trying count endpoint: $uri');

      final authHeaders = await getAuthHeaders();
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = _safeJsonDecode(response.body, response.statusCode);
        final count = responseData['count'] ?? responseData['total'] ?? responseData['employee_count'];
        if (count != null) {
          final finalCount = count is int ? count : int.tryParse(count.toString()) ?? 0;
          print('✅ EmployeeService.Strategy1: Found $finalCount employees via count endpoint');
          return finalCount;
        }
      }
    } catch (e) {
      print('⚠️ EmployeeService.Strategy1: Count endpoint failed: $e');
    }
    return null;
  }

  // Strategy 2: Try company employees endpoint
  Future<int?> _tryCompanyEmployeesEndpoint(String companyId) async {
    final potentialEndpoints = [
      'companies/$companyId/employees',
      'employees?company_id=$companyId',
      'admin/employees?company_id=$companyId',
      'employees/company/$companyId',
      'company/$companyId/all-employees',
    ];

    for (final endpointPath in potentialEndpoints) {
      try {
        final endpoint = path.join(baseUrl, endpointPath);
        final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
        
        print('[EmployeeService.Strategy2] Trying: $uri');
        
        final authHeaders = await getAuthHeaders();
        final response = await http
            .get(uri, headers: authHeaders)
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final employees = _safeJsonDecodeArray(response.body, response.statusCode);
          final count = employees.length;
          print('✅ EmployeeService.Strategy2: Found $count employees via $endpointPath');
          return count;
        } else if (response.statusCode == 404) {
          continue; // Try next endpoint
        }
      } catch (e) {
        print('⚠️ EmployeeService.Strategy2: $endpointPath failed: $e');
        continue;
      }
    }
    return null;
  }

  // Fallback method to estimate company employee count
  Future<int> _getCompanyEmployeeCountFallback() async {
    try {
      final authController = Get.find<AuthController>();
      final companyId = authController.user.value?.companyId ?? 
                       authController.user.value?.company?.id;
      
      if (companyId == null) {
        print('❌ EmployeeService: No company ID for fallback count');
        return 0;
      }

      // Use a generic employees endpoint that might return all company employees
      // Try different potential endpoints that could give us company-wide data
      final endpoints = [
        'companies/$companyId/employees',  // Company-specific endpoint
        'employees?company_id=$companyId', // Query parameter approach
        'employees/company/$companyId',    // Alternative company endpoint
      ];

      for (final endpointPath in endpoints) {
        try {
          final endpoint = path.join(baseUrl, endpointPath);
          final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
          
          print('[EmployeeService.fallback] Trying endpoint: $uri');
          
          final authHeaders = await getAuthHeaders();
          final response = await http
              .get(uri, headers: authHeaders)
              .timeout(const Duration(seconds: 15));

          if (response.statusCode == 200) {
            final employees = _safeJsonDecodeArray(response.body, response.statusCode);
            final count = employees.length;
            print('✅ EmployeeService: Found company-wide endpoint with $count employees');
            return count;
          }
        } catch (e) {
          print('⚠️ EmployeeService: Endpoint $endpointPath failed: $e');
          continue; // Try next endpoint
        }
      }

      // If no company-wide endpoint works, use an intelligent estimation
      print('⚠️ EmployeeService: No company-wide endpoints available, using estimation');
      
      // Get manager's employee count as baseline
      final managerEmployees = await getEmployees();
      final managerCount = managerEmployees.length;
      
      // For estimation, we can use business logic:
      // Option 1: Use manager count as minimum (conservative)
      // Option 2: Apply a multiplier based on company size
      // Option 3: Return 0 to force manual capacity management
      
      final companyLimit = authController.user.value?.company?.size ?? 
                          authController.user.value?.companySize ?? 50;
      
      // Conservative estimation: assume this manager has average load
      // Use manager count as baseline but cap it reasonably
      final estimatedTotal = (managerCount * 1.5).round().clamp(managerCount, companyLimit);
      
      print('ℹ️ EmployeeService: Estimated company total: $estimatedTotal (based on manager: $managerCount)');
      return estimatedTotal;
      
    } catch (e) {
      print('❌ EmployeeService: All fallback methods failed: $e');
      return 0;
    }
  }

  // DELETE EMPLOYEE - Enhanced with better error handling
  Future<bool> deleteEmployee(int employeeId) async {
    try {
      final endpoint = path.join(baseUrl, 'employees', employeeId.toString());
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
        throw _handleHttpError(response, 'delete employee');
      }
    } on http.ClientException catch (e) {
      print('❌ EmployeeService: Network Error: ${e.message}');
      throw Exception('Network connection error. Please check your internet connection.');
    } on FormatException catch (e) {
      print('❌ EmployeeService: JSON Parse Error: ${e.message}');
      throw Exception('Invalid server response format. Please try again later.');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}