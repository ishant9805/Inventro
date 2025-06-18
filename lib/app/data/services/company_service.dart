import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'package:get_storage/get_storage.dart';

class CompanyService {
  final String baseUrl = 'https://backend.tecsohub.com';

  // Enhanced method to fetch company by ID with better error handling
  Future<Map<String, dynamic>?> getCompanyById(String companyId) async {
    try {
      // Build the endpoint URL properly
      final endpoint = '$baseUrl/companies/$companyId';
      final uri = Uri.parse(endpoint);
      
      print('[CompanyService.getCompanyById] endpoint: $endpoint');
      print('[CompanyService.getCompanyById] uri: $uri');
      
      // Retrieve token from secure storage
      final storage = GetStorage();
      final token = storage.read('token');
      
      print('[CompanyService.getCompanyById] token exists: ${token != null}');
      
      if (token == null || token.isEmpty) {
        print('[CompanyService.getCompanyById] No token found, redirecting to register');
        return null;
      }
      
      // Prepare headers
      final headers = {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      
      print('[CompanyService.getCompanyById] Making request with headers: ${headers.keys.toList()}');
      
      // Make the HTTP request
      final response = await http.get(uri, headers: headers);
      
      print('[CompanyService.getCompanyById] status: ${response.statusCode}');
      print('[CompanyService.getCompanyById] body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('[CompanyService.getCompanyById] Successfully fetched company data');
        return responseData;
      } else if (response.statusCode == 401) {
        // Token is invalid or expired
        print('[CompanyService.getCompanyById] Authentication failed - clearing token');
        storage.remove('token'); // Clear the invalid token
        Get.offAllNamed('/register');
        return null;
      } else if (response.statusCode == 404) {
        // Company not found
        print('[CompanyService.getCompanyById] Company not found');
        return null;
      } else {
        // Other errors
        print('[CompanyService.getCompanyById] Request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[CompanyService.getCompanyById] Exception occurred: $e');
      return null;
    }
  }

  // Create new company with enhanced error handling
  Future<Map<String, dynamic>?> createCompany({required String name, required int size}) async {
    try {
      final endpoint = '$baseUrl/companies/';
      final uri = Uri.parse(endpoint);
      
      print('[CompanyService.createCompany] endpoint: $endpoint');
      print('[CompanyService.createCompany] Creating company with name: $name, size: $size');
      
      final headers = {
        'accept': 'application/json', 
        'Content-Type': 'application/json'
      };
      
      final body = jsonEncode({'name': name, 'size': size});
      print('[CompanyService.createCompany] Request body: $body');
      
      final response = await http.post(uri, headers: headers, body: body);
      
      print('[CompanyService.createCompany] Response status: ${response.statusCode}');
      print('[CompanyService.createCompany] Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // The backend always returns a company object with an id field
        if (data is Map<String, dynamic> && data['id'] != null) {
          print('[CompanyService.createCompany] Company created successfully with ID: ${data['id']}');
          return data;
        } else {
          print('[CompanyService.createCompany] Invalid response structure: $data');
          return null;
        }
      } else if (response.statusCode == 422) {
        // Validation error
        print('[CompanyService.createCompany] Validation error: ${response.body}');
        return null;
      } else {
        print('[CompanyService.createCompany] Request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[CompanyService.createCompany] Exception occurred: $e');
      return null;
    }
  }

  // Helper method to check if token is valid
  Future<bool> isTokenValid() async {
    final storage = GetStorage();
    final token = storage.read('token');
    
    if (token == null || token.isEmpty) {
      return false;
    }
    
    try {
      // Test token validity by making a simple request
      // You can replace this with your actual token verification endpoint
      final headers = {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      
      // Using a simple endpoint to test token - adjust as needed
      final response = await http.get(
        Uri.parse('$baseUrl/companies/'), // This might be a protected endpoint
        headers: headers,
      );
      
      return response.statusCode != 401;
    } catch (e) {
      print('[CompanyService.isTokenValid] Error checking token: $e');
      return false;
    }
  }

  // Method to refresh token if you have refresh token functionality
  Future<bool> refreshToken() async {
    final storage = GetStorage();
    final refreshToken = storage.read('refresh_token');
    
    if (refreshToken == null) {
      print('[CompanyService.refreshToken] No refresh token found');
      return false;
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'), // Adjust this endpoint according to your backend
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        storage.write('token', data['access_token']);
        if (data['refresh_token'] != null) {
          storage.write('refresh_token', data['refresh_token']);
        }
        print('[CompanyService.refreshToken] Token refreshed successfully');
        return true;
      } else {
        print('[CompanyService.refreshToken] Failed to refresh token: ${response.statusCode}');
      }
    } catch (e) {
      print('[CompanyService.refreshToken] Error refreshing token: $e');
    }
    
    return false;
  }

  // Enhanced method with token refresh capability
  Future<Map<String, dynamic>?> getCompanyByIdWithRefresh(String companyId) async {
    // First attempt
    var result = await getCompanyById(companyId);
    
    if (result == null) {
      // Try refreshing token and retry once
      if (await refreshToken()) {
        print('[CompanyService.getCompanyByIdWithRefresh] Token refreshed, retrying...');
        result = await getCompanyById(companyId);
      }
    }
    
    return result;
  }

  // Debug method to check token storage
  void debugTokenStorage() {
    final storage = GetStorage();
    final token = storage.read('token');
    print('[CompanyService.debugTokenStorage] Stored token: ${token != null ? 'EXISTS' : 'NULL'}');
    if (token != null) {
      print('[CompanyService.debugTokenStorage] Token length: ${token.length}');
      print('[CompanyService.debugTokenStorage] Token starts with: ${token.substring(0, min(20, token.length))}...');
    }
  }

  // Method to clear all stored tokens
  void clearTokens() {
    final storage = GetStorage();
    storage.remove('token');
    storage.remove('refresh_token');
    print('[CompanyService.clearTokens] All tokens cleared');
  }
}