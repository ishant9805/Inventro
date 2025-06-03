import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../modules/auth/controller/auth_controller.dart';
import 'package:path/path.dart' as path;

class EmployeeService {
  final String baseUrl = 'https://backend.tecsohub.com/';

  // Helper method to get auth headers with token
  Map<String, String> getAuthHeaders() {
    final authController = Get.find<AuthController>();
    final tokenValue = authController.user.value?.token;

    if (tokenValue == null || tokenValue.isEmpty) {
      throw Exception('No authentication token found. Please login again.');
    }

    final token = tokenValue.trim();
    if (token.isEmpty) {
      throw Exception(
        'Authentication token is empty after trimming. Please login again.',
      );
    }

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    return headers;
  }

  // Helper method to safely parse JSON response
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
      };
    }
  }

  // Helper method to safely parse JSON array response
  List<Map<String, dynamic>> _safeJsonDecodeArray(
    String responseBody,
    int statusCode,
  ) {
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
      return [];
    }
  }

  // ADD EMPLOYEE
  Future<Map<String, dynamic>> addEmployee(
    Map<String, dynamic> employeeData,
  ) async {
    try {
      // Fix: Remove trailing slash to avoid 307 redirect
      final endpoint = path.join(baseUrl, 'register/employee');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      print('[EmployeeService.addEmployee] Received employeeData: $employeeData');
      print('[EmployeeService.addEmployee] Request URI: $uri');

      final authHeaders = getAuthHeaders();
      final requestHeaders = {
        ...authHeaders,
        'Content-Type': 'application/json',
      };

      print('[EmployeeService.addEmployee] Request headers: $requestHeaders');
      print('[EmployeeService.addEmployee] Request body: ${jsonEncode(employeeData)}');

      final response = await http
          .post(
            uri,
            headers: requestHeaders,
            body: jsonEncode(employeeData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - please check your internet connection',
              );
            },
          );

      print('[EmployeeService.addEmployee] Response Status Code: ${response.statusCode}');
      print('[EmployeeService.addEmployee] Response Body: ${response.body}');

      // Handle redirect responses
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
          print('[EmployeeService.addEmployee] Redirect Response Body: ${redirectResponse.body}');

          if (redirectResponse.statusCode == 200 || redirectResponse.statusCode == 201) {
            final responseData = _safeJsonDecode(
              redirectResponse.body,
              redirectResponse.statusCode,
            );
            if (responseData['error'] == true) {
              throw Exception(responseData['message'] ?? 'Failed to add employee');
            }
            return responseData;
          } else {
            final errorData = _safeJsonDecode(redirectResponse.body, redirectResponse.statusCode);
            throw Exception(
              errorData['message'] ??
                  errorData['detail'] ??
                  'Failed to add employee after redirect (${redirectResponse.statusCode})',
            );
          }
        } else {
          throw Exception('Received redirect response but no location header found');
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = _safeJsonDecode(
          response.body,
          response.statusCode,
        );
        if (responseData['error'] == true) {
          throw Exception(responseData['message'] ?? 'Failed to add employee');
        }
        return responseData;
      } else {
        final errorData = _safeJsonDecode(response.body, response.statusCode);
        throw Exception(
          errorData['message'] ??
              errorData['detail'] ??
              'Failed to add employee (${response.statusCode})',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Network connection error. Please check your internet connection.',
      );
    } on FormatException {
      throw Exception(
        'Invalid server response format. Please try again later.',
      );
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // GET ALL EMPLOYEES FOR MANAGER
  Future<List<Map<String, dynamic>>> getEmployees() async {
    try {
      final endpoint = path.join(baseUrl, 'employees/');
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      print('[EmployeeService.getEmployees] Request URI: $uri');
      print('[EmployeeService.getEmployees] Request Headers: \\${getAuthHeaders()}');

      final response = await http
          .get(uri, headers: getAuthHeaders())
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - please check your internet connection',
              );
            },
          );

      print('[EmployeeService.getEmployees] Response Status Code: \\${response.statusCode}');
      print('[EmployeeService.getEmployees] Response Body: \\${response.body}');

      if (response.statusCode == 200) {
        return _safeJsonDecodeArray(response.body, response.statusCode);
      } else {
        final errorData = _safeJsonDecode(response.body, response.statusCode);
        throw Exception(
          errorData['message'] ??
              errorData['detail'] ??
              'Failed to fetch employees (\\${response.statusCode})',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Network connection error. Please check your internet connection.',
      );
    } on FormatException {
      throw Exception(
        'Invalid server response format. Please try again later.',
      );
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: \\${e.toString()}');
    }
  }

  // DELETE EMPLOYEE
  Future<bool> deleteEmployee(int employeeId) async {
    try {
      final endpoint = path.join(baseUrl, 'employees', employeeId.toString());
      final uri = Uri.parse(endpoint.replaceAll('\\', '/'));

      final response = await http
          .delete(uri, headers: getAuthHeaders())
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - please check your internet connection',
              );
            },
          );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 202) {
        return true;
      } else {
        final errorData = _safeJsonDecode(response.body, response.statusCode);
        throw Exception(
          errorData['message'] ??
              errorData['detail'] ??
              'Failed to delete employee (${response.statusCode})',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Network connection error. Please check your internet connection.',
      );
    } on FormatException {
      throw Exception(
        'Invalid server response format. Please try again later.',
      );
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}