import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'employee_user';

  // ─── Send OTP ───────────────────────────────────────────────
  /// Returns the full response map on success.
  static Future<Map<String, dynamic>> sendOtp(String mobile) async {
    return await ApiService.post(
      '/employeeUser/sendotp',
      body: {'mobile_number': mobile},
    );
  }

  // ─── Verify OTP ─────────────────────────────────────────────
  /// On success, persists token + user details and returns the response.
  static Future<Map<String, dynamic>> verifyOtp(
    String mobile,
    String otp, {
    String? fcmToken,
  }) async {
    final data = await ApiService.post(
      '/employeeUser/verifyotp',
      body: {
        'mobile_number': mobile,
        'otp': otp,
        'fcm_token': ?fcmToken,
      },
    );
    // print(fcmToken);
    // Persist token & user details
    if (data['IsSuccess'] == true && data['Data'] != null) {
      final prefs = await SharedPreferences.getInstance();
      final responseData = data['Data'] as Map<String, dynamic>;

      final token = responseData['accesstoken'] as String?;
      if (token != null) {
        await prefs.setString(_tokenKey, token);
      }

      final userDetails = responseData['employeeUserdetails'];
      if (userDetails != null) {
        await prefs.setString(_userKey, jsonEncode(userDetails));
      }
    }

    return data;
  }

  // ─── Token helpers ──────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getToken() => ApiService.getToken();

  // ─── User details ──────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  // ─── Logout ─────────────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
