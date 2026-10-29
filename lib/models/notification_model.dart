/// Model Notification — sesuai response API Backend Laravel DatabaseNotifications.
class NotificationModel {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final String? readAt;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : {},
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  bool get isRead => readAt != null;

  String get title => data['title']?.toString() ?? 'Notifikasi Perizinan';
  String get message => data['message']?.toString() ?? '';
  int? get permohonanId => data['permohonan_id'] as int?;
  String? get status => data['status']?.toString();
}
