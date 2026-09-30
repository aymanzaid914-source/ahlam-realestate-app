// lib/providers/notifications_provider.dart
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../constants.dart';

class NotificationsProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _loading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _loading;

  Future<void> load(String? token) async {
    if (token == null) return;
    _loading = true;
    notifyListeners();
    try {
      final api = ApiService(token: token);
      final resp = await api.get(AppConstants.notificationsEndpoint, queryParams: {'per_page': '30'});
      final data = resp.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      _notifications = items.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
      _unreadCount   = data['unread'] as int? ?? 0;
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<void> markAllRead(String token) async {
    try {
      final api = ApiService(token: token);
      await api.post(AppConstants.notificationsEndpoint, {'action': 'mark_read'});
      _unreadCount = 0;
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id, title: n.title, body: n.body, type: n.type,
        link: n.link, isRead: true, readAt: n.readAt, createdAt: n.createdAt,
      )).toList();
      notifyListeners();
    } catch (_) {}
  }
}
