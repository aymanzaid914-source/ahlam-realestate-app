// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;

  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success : json['success'] == true,
      message : json['message']?.toString() ?? '',
      data    : json['data'],
    );
  }
}

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  final String? _token;
  ApiService({String? token}) : _token = token;

  Map<String, String> get _headers {
    final h = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  Future<ApiResponse> _handleResponse(http.Response response) async {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('فشل في قراءة الاستجابة من الخادم', statusCode: response.statusCode);
    }

    final apiResp = ApiResponse.fromJson(json);

    if (!apiResp.success) {
      final errors = json['errors'] as Map<String, dynamic>?;
      throw ApiException(
        apiResp.message.isNotEmpty ? apiResp.message : 'حدث خطأ غير متوقع',
        statusCode: response.statusCode,
        errors: errors,
      );
    }

    return apiResp;
  }

  // ─── GET ────────────────────────────────────────────────────────────────
  Future<ApiResponse> get(String url, {Map<String, String>? queryParams}) async {
    Uri uri = Uri.parse(url);
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...queryParams,
      });
    }
    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت. تحقق من شبكتك وحاول مجدداً');
    } on HttpException {
      throw ApiException('حدث خطأ في الاتصال بالخادم');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('انتهت مهلة الاتصال. تحقق من شبكتك وحاول مجدداً');
    }
  }

  // ─── POST ───────────────────────────────────────────────────────────────
  Future<ApiResponse> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت. تحقق من شبكتك وحاول مجدداً');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('انتهت مهلة الاتصال. تحقق من شبكتك وحاول مجدداً');
    }
  }

  // ─── PUT ────────────────────────────────────────────────────────────────
  Future<ApiResponse> put(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت. تحقق من شبكتك وحاول مجدداً');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('انتهت مهلة الاتصال. تحقق من شبكتك وحاول مجدداً');
    }
  }
}
