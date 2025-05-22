import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:path/path.dart' as path;

class AuthService {
  final String baseUrl = 'https://757e-2401-4900-b3f7-3eb2-a9d5-4490-37f1-897.ngrok-free.app/';

  // REGISTER
  Future<bool> registerAdmin(Map<String, dynamic> body) async {
    final endpoint = path.join(baseUrl, 'register/manager');
    final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

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
  
  //print(response.statusCode);
  //print(response.body);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Handle token here
    return UserModel.fromJson(data); // OR TokenModel.fromJson(data)
  } else {
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Login failed');
  }
}

}
