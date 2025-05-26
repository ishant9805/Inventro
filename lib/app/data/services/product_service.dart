import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../modules/auth/controller/auth_controller.dart';

class ProductService {
  static const String baseUrl = 'https://inventro-backend.vercel.app/';

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

  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}products'),
        headers: getAuthHeaders(),
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}products'),
        headers: getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch products: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}