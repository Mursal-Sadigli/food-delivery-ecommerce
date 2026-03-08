import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Windows Desktop proqramları üçün
  static const String baseUrl = 'http://127.0.0.1:5000/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      print('API Response STATUS $endpoint: ${response.statusCode}');
      print('API Response BODY $endpoint: ${response.body}');
      if (response.statusCode >= 400) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
      return jsonDecode(response.body);
    } catch (e) {
      print('HTTP POST ERROR: $e');
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode >= 400) {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
    return jsonDecode(response.body);
  }

  Future<dynamic> delete(String endpoint) async {
    final token = await getToken();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      print('API Response STATUS $endpoint: ${response.statusCode}');
      print('API Response BODY $endpoint: ${response.body}');
      if (response.statusCode >= 400) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
      return jsonDecode(response.body);
    } catch (e) {
      print('HTTP DELETE ERROR: $e');
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode >= 400) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
      return jsonDecode(response.body);
    } catch (e) {
      print('HTTP PUT ERROR: $e');
      rethrow;
    }
  }
}
