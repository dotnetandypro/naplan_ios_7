import 'dart:convert';
import 'package:http/http.dart' as http;
import 'request_settings.dart';

class ApiService {
  // Get base URL from centralized RequestSettings
  static String get baseUrl => RequestSettings.baseUrl;

  // Get request headers from centralized RequestSettings
  static Map<String, String> get headers => RequestSettings.getHeaders();

  // GET request
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return http.get(url, headers: headers);
  }

  // POST request
  static Future<http.Response> post(String endpoint, dynamic body) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    String jsonBody = json.encode(body);
    return http.post(url, headers: headers, body: jsonBody);
  }

  // PUT request
  static Future<http.Response> put(String endpoint, dynamic body) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    String jsonBody = json.encode(body);
    return http.put(url, headers: headers, body: jsonBody);
  }

  // DELETE request
  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return http.delete(url, headers: headers);
  }
}
