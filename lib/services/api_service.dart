import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  static const String baseUrl = 'https://apihrms.bookwithkhushi.com';
  static const String imageBaseUrl =
      'https://hrms-khushi.s3.ap-south-1.amazonaws.com/';
  static const String _tokenKey = 'access_token';
  static const bool _logResponses = true;

  /// GET the stored token (null if not logged in).
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// POST request with optional auth header.
  /// Returns the decoded JSON body.
  /// Throws [ApiException] on non-2xx or 401.
  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    _log('──── POST $path ────');
    _log('URL: $uri');
    _log('Payload: ${jsonEncode(body)}');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    _log('Status: ${response.statusCode}');
    _log('Response: ${response.body}');
    _log('──── END POST $path ────');

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Handle 401 — token expired / invalid
    if (response.statusCode == 401) {
      await clearToken();
      throw ApiException('Session expired. Please login again.', 401);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data['Message'] ?? 'Something went wrong';
      throw ApiException(message.toString(), response.statusCode);
    }

    return data;
  }

  /// GET request with optional auth header.
  static Future<Map<String, dynamic>> get(
    String path, {
    bool requiresAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    _log('──── GET $path ────');
    _log('URL: $uri');

    final response = await http.get(uri, headers: headers);

    _log('Status: ${response.statusCode}');
    _log('Response: ${response.body}');
    _log('──── END GET $path ────');

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 401) {
      await clearToken();
      throw ApiException('Session expired. Please login again.', 401);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data['Message'] ?? 'Something went wrong';
      throw ApiException(message.toString(), response.statusCode);
    }

    return data;
  }

  /// Multi-part POST request for file uploads.
  static Future<Map<String, dynamic>> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'image',
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);

    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
    final mediaType = MediaType.parse(mimeType);

    request.files.add(
      await http.MultipartFile.fromPath(
        fieldName,
        filePath,
        contentType: mediaType,
      ),
    );

    _log('──── MULTIPART POST $path ────');
    _log('URL: $uri');
    _log('File: $filePath');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    _log('Status: ${response.statusCode}');
    _log('Response: ${response.body}');
    _log('──── END MULTIPART POST $path ────');

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 401) {
      await clearToken();
      throw ApiException('Session expired. Please login again.', 401);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data['Message'] ?? 'Something went wrong';
      throw ApiException(message.toString(), response.statusCode);
    }

    return data;
  }

  /// Clear stored token (called on 401 or logout).
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Centralized logging so every API request/response is printed to the console.
  /// Uses both `developer.log` (for observatory/logcat) and `debugPrint` to keep
  /// visibility in debug sessions. Toggle with [_logResponses] if needed.
  static void _log(String message) {
    if (!_logResponses) return;
    developer.log(message, name: 'ApiService');
    // debugPrint handles long messages by chunking internally.
    debugPrint(message);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
