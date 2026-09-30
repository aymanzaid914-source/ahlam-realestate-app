// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<NotificationsProvider>().load(auth.token);
    });
  }

  IconData _notifIcon(String type) {
    return switch (type) {
      'reservation' => Icons.calendar_today,
      'payment'     => Icons.payments_outlined,
      'account'     => Icons.person_outline,
      'customer'    => Icons.people_outline,
      _             => Icons.notifications_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          Consumer<NotificationsProvider>(
            builder: (_, notifs, __) {
              if (notifs.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  final auth = context.read<AuthProvider>();
                  if (auth.token != null) notifs.markAllRead(auth.token!);
                },
                child: const Text('قراءة الكل', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<NotificationsProvider>(
        builder: (_, notifs, __) {
          if (notifs.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (notifs.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد إشعارات', style: TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontSize: 15)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final auth = context.read<AuthProvider>();
              await notifs.load(auth.token);
            },
            child: ListView.builder(
              itemCount: notifs.notifications.length,
              itemBuilder: (_, i) {
                final n = notifs.notifications[i];
                return _NotifTile(notif: n, icon: _notifIcon(n.type));
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;
  final IconData icon;

  const _NotifTile({required this.notif, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notif.isRead ? Colors.transparent : const Color(0xFF1A3B5C).withValues(alpha: 0.04),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: notif.isRead
                ? Colors.grey.withValues(alpha: 0.1)
                : const Color(0xFF1A3B5C).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 22,
            color: notif.isRead ? Colors.grey : const Color(0xFF1A3B5C),
          ),
        ),
        title: Text(
          notif.title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notif.body != null)
              Text(notif.body!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)),
            Text(notif.createdAt, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        isThreeLine: notif.body != null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
    );
  }
}
