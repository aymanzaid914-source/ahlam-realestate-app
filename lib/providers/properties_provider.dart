// lib/providers/properties_provider.dart
import 'package:flutter/foundation.dart';
import '../models/property.dart';
import '../services/api_service.dart';
import '../constants.dart';

class PropertiesProvider extends ChangeNotifier {
  List<Property> _properties  = [];
  List<Property> _featured    = [];
  List<Property> _favorites   = [];
  bool _loading      = false;
  bool _loadingMore  = false;
  String? _error;
  int _currentPage   = 1;
  int _totalPages    = 1;
  int _total         = 0;
  Map<String, String> _currentFilters = {};

  List<Property> get properties  => _properties;
  List<Property> get featured    => _featured;
  List<Property> get favorites   => _favorites;
  bool get isLoading      => _loading;
  bool get isLoadingMore  => _loadingMore;
  String? get error       => _error;
  int get total           => _total;
  bool get hasMore        => _currentPage < _totalPages;

  Future<void> loadFeatured(String? token) async {
    try {
      final api = ApiService(token: token);
      final resp = await api.get(
        AppConstants.propertiesEndpoint,
        queryParams: {'featured': 'true', 'per_page': '8', 'status': 'available'},
      );
      final data = resp.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      _featured = items.map((e) => Property.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadProperties({
    String? token,
    Map<String, String>? filters,
    bool reset = true,
  }) async {
    if (reset) {
      _loading = true;
      _error   = null;
      _currentPage = 1;
      _currentFilters = filters ?? {};
      notifyListeners();
    } else {
      _loadingMore = true;
      notifyListeners();
    }

    try {
      final api = ApiService(token: token);
      final params = <String, String>{
        'page'    : _currentPage.toString(),
        'per_page': AppConstants.pageSize.toString(),
        ..._currentFilters,
      };

      final resp = await api.get(AppConstants.propertiesEndpoint, queryParams: params);
      final data = resp.data as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>? ?? [])
          .map((e) => Property.fromJson(e as Map<String, dynamic>))
          .toList();

      _total       = data['total'] as int? ?? 0;
      _totalPages  = data['total_pages'] as int? ?? 1;

      if (reset) {
        _properties = items;
      } else {
        _properties.addAll(items);
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'حدث خطأ في تحميل العقارات';
    } finally {
      _loading     = false;
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore(String? token) async {
    if (!hasMore || _loadingMore) return;
    _currentPage++;
    await loadProperties(token: token, reset: false);
  }

  Future<Property?> getPropertyDetail(String? token, {int? id, String? slug}) async {
    try {
      final api = ApiService(token: token);
      final params = <String, String>{};
      if (id != null) params['id'] = id.toString();
      if (slug != null) params['slug'] = slug;

      final resp = await api.get(AppConstants.propertyDetailEndpoint, queryParams: params);
      final data = resp.data as Map<String, dynamic>;
      return Property.fromJson(data['property'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadFavorites(String? token) async {
    if (token == null) { _favorites = []; return; }
    try {
      final api = ApiService(token: token);
      final resp = await api.get(AppConstants.favoritesEndpoint);
      final data = resp.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      _favorites = items.map((e) => Property.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> toggleFavorite(String token, int propertyId) async {
    try {
      final api = ApiService(token: token);
      final resp = await api.post(AppConstants.favoritesEndpoint, {'property_id': propertyId});
      final data = resp.data as Map<String, dynamic>;
      final isFav = data['is_favorite'] as bool? ?? false;
      if (isFav) {
        // إضافة للمفضلة محلياً (يتطلب بيانات كاملة للعقار)
        _favorites.removeWhere((p) => p.id == propertyId);
      } else {
        _favorites.removeWhere((p) => p.id == propertyId);
      }
      notifyListeners();
      return isFav;
    } catch (_) {
      return false;
    }
  }
}
