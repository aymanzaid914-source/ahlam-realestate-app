// lib/providers/projects_provider.dart
import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import '../constants.dart';

class ProjectsProvider extends ChangeNotifier {
  List<Project> _projects = [];
  bool _loading = false;
  String? _error;

  List<Project> get projects => _projects;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> loadProjects(String? token) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      final api = ApiService(token: token);
      final resp = await api.get(AppConstants.projectsEndpoint, queryParams: {'per_page': '20'});
      final data = resp.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      _projects = items.map((e) => Project.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'حدث خطأ في تحميل المشاريع';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getProjectDetail(String? token, {int? id, String? slug}) async {
    try {
      final api = ApiService(token: token);
      final params = <String, String>{};
      if (id != null) params['id'] = id.toString();
      if (slug != null) params['slug'] = slug;

      final resp = await api.get(AppConstants.projectDetailEndpoint, queryParams: params);
      return resp.data as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
