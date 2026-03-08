import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Windows Desktop proqramları üçün
  static const String baseUrl = 'http://localhost:5000/api';

  Uri _buildUri(String endpoint) {
    // baseUrl və endpoint-i birləşdirərkən boşluqları və slash-ləri yoxla
    String host = baseUrl.trim();
    if (host.endsWith('/')) {
      host = host.substring(0, host.length - 1);
    }
    String path = endpoint.trim();
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    final fullUrl = '$host$path'.trim();
    return Uri.parse(fullUrl);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    final uri = _buildUri(endpoint);
    try {
      print('HTTP POST: $uri');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      print('API Response STATUS $endpoint: ${response.statusCode}');
      if (response.statusCode >= 400) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
      return jsonDecode(response.body);
    } catch (e) {
      print('HTTP POST ERROR [$uri]: $e');
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint) async {
    final token = await getToken();
    final uri = _buildUri(endpoint);
    try {
      print('HTTP GET: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 400) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
      return jsonDecode(response.body);
    } catch (e) {
      print('HTTP GET ERROR [$uri]: $e');
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final token = await getToken();
    final uri = _buildUri(endpoint);
    try {
      print('HTTP DELETE: $uri');
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      print('API Response STATUS $endpoint: ${response.statusCode}');
      if (response.statusCode >= 400) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
      return jsonDecode(response.body);
    } catch (e) {
      print('HTTP DELETE ERROR [$uri]: $e');
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    final uri = _buildUri(endpoint);
    try {
      print('HTTP PUT: $uri');
      final response = await http.put(
        uri,
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
      print('HTTP PUT ERROR [$uri]: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkMaintenanceStatus() async {
    final uri = _buildUri('/settings/public');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'isMaintenanceMode': false};
    } catch (e) {
      print('Maintenance Status Error: $e');
      // Serverə qoşulmaq mümkün deyilsə, təhlükəsizlik üçün bloklayırıq
      return {'isMaintenanceMode': true, 'error': e.toString()};
    }
  }
}
