// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  Customer? _customer;
  String? _token;
  String? _error;
  bool _loading = false;

  AuthStatus get status   => _status;
  Customer? get customer  => _customer;
  String? get token       => _token;
  String? get error       => _error;
  bool get isLoading      => _loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// تهيئة عند بدء التطبيق
  Future<void> initAuth() async {
    try {
      final saved = await AuthService.getSavedAuth();
      if (saved != null) {
        _token    = saved['token'] as String;
        _customer = saved['customer'] as Customer;
        _status   = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      final result = await AuthService.login(identifier, password);
      _token    = result['token'] as String;
      _customer = result['customer'] as Customer;
      _status   = AuthStatus.authenticated;
      _loading  = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error   = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error   = 'حدث خطأ غير متوقع. يرجى المحاولة مجدداً.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    String? email,
    required String password,
  }) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      await AuthService.register(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
      );
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error   = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error   = 'حدث خطأ غير متوقع. يرجى المحاولة مجدداً.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      await AuthService.logout(_token!);
    }
    _token    = null;
    _customer = null;
    _status   = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void updateCustomer(Customer customer) {
    _customer = customer;
    notifyListeners();
  }
}
