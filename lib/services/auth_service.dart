// lib/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../constants.dart';
import '../models/customer.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    final api = ApiService();
    final response = await api.post(AppConstants.loginEndpoint, {
      'identifier': identifier,
      'password': password,
      'device_type': 'android',
    });

    final data = response.data as Map<String, dynamic>;
    final token = data['token']?.toString() ?? '';
    final customerData = data['customer'] as Map<String, dynamic>;
    final expiresAt = data['expires_at']?.toString() ?? '';

    // حفظ التوكن
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.customerKey, jsonEncode(customerData));
    await prefs.setString(AppConstants.expiresKey, expiresAt);

    return {
      'token': token,
      'customer': Customer.fromJson(customerData),
    };
  }

  static Future<void> register({
    required String fullName,
    required String phone,
    String? email,
    required String password,
  }) async {
    final api = ApiService();
    await api.post(AppConstants.registerEndpoint, {
      'full_name': fullName,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      'password': password,
    });
  }

  static Future<void> logout(String token) async {
    try {
      final api = ApiService(token: token);
      await api.post(AppConstants.logoutEndpoint, {});
    } catch (_) {}
    // حذف البيانات المحلية دائماً
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.customerKey);
    await prefs.remove(AppConstants.expiresKey);
  }

  static Future<Map<String, dynamic>?> getSavedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final customerJson = prefs.getString(AppConstants.customerKey);
    final expiresAt = prefs.getString(AppConstants.expiresKey);

    if (token == null || customerJson == null) return null;

    // التحقق من انتهاء الصلاحية
    if (expiresAt != null) {
      final expiry = DateTime.tryParse(expiresAt);
      if (expiry != null && expiry.isBefore(DateTime.now())) {
        await prefs.remove(AppConstants.tokenKey);
        await prefs.remove(AppConstants.customerKey);
        return null;
      }
    }

    try {
      final customerData = jsonDecode(customerJson) as Map<String, dynamic>;
      return {
        'token': token,
        'customer': Customer.fromJson(customerData),
      };
    } catch (_) {
      return null;
    }
  }
}
