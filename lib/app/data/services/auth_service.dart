import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import '../../modules/auth/controller/auth_controller.dart';

class AuthService {
  final String baseUrl = 'https://inventro-backend.vercel.app/';

  // Helper method to get auth headers with token
  Map<String, String> getAuthHeaders() {
    final authController = Get.find<AuthController>();
    final token = authController.user.value?.token;
    
    final headers = {'Content-Type': 'application/json'};
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // REGISTER
  Future<bool> registerAdmin(Map<String, dynamic> body) async {
    final endpoint = path.join(baseUrl, 'register/manager');
    final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
    //print(uri);
    
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    //print(response.statusCode);

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Registration failed',
      );
    }
  }

  // LOGIN
  Future<UserModel> login(String email, String password) async {
    final endpoint = path.join(baseUrl, 'token');
    final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email,
        'password': password,
      },
    );
    
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Store token in UserModel
      return UserModel(
        name: 'User', // Default or from response if available
        email: email,
        role: 'manager', // Default or from response if available
        token: data['access_token'],
      );
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Login failed');
    }
  }

  // FETCH USER PROFILE
  Future<UserModel> fetchUserProfile(String token) async {
    final endpoint = path.join(baseUrl, 'user/profile');
    final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
    
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Create a full user model with both token and profile data
      return UserModel.fromJson({
        ...data,
        'token': token, // Ensure the token is included
      });
    } else {
      throw Exception('Failed to load user profile');
    }
  }

}
