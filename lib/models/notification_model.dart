// lib/models/notification_model.dart
class NotificationModel {
  final int id;
  final String title;
  final String? body;
  final String type;
  final String? link;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    this.body,
    required this.type,
    this.link,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id        : json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title     : json['title']?.toString() ?? '',
      body      : json['body']?.toString(),
      type      : json['type']?.toString() ?? 'system',
      link      : json['link']?.toString(),
      isRead    : json['is_read'] == true || json['is_read'] == 1,
      readAt    : json['read_at']?.toString(),
      createdAt : json['created_at']?.toString() ?? '',
    );
  }
}
