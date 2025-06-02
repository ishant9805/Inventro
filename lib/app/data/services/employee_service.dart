import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class EmployeeService {
  final String baseUrl = 'https://backend.tecsohub.com/';

  Future<void> addEmployee(Map<String, dynamic> data) async {
    final endpoint = path.join(baseUrl, 'register/employee');
    final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add employee: ${response.body}');
    }
  }
}