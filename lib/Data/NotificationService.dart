import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService with ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _notificationsEnabled = true;

  List<AppNotification> get notifications => _notifications;
  bool get notificationsEnabled => _notificationsEnabled;

  static const String _notificationsKey = 'app_notifications';
  static const String _enabledKey = 'notifications_enabled';

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load notifications
    final notificationsJson = prefs.getString(_notificationsKey);
    if (notificationsJson != null) {
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      _notifications = notificationsList.map((item) => AppNotification.fromJson(item)).toList();
    }

    // Load enabled state
    _notificationsEnabled = prefs.getBool(_enabledKey) ?? true;
    
    notifyListeners();
  }

  Future<void> saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save notifications
    final notificationsJson = json.encode(_notifications.map((notification) => notification.toJson()).toList());
    await prefs.setString(_notificationsKey, notificationsJson);

    // Save enabled state
    await prefs.setBool(_enabledKey, _notificationsEnabled);
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    saveNotifications();
    notifyListeners();
  }

  void addNotification(String title, String message, NotificationType type) {
    if (!_notificationsEnabled) return;

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, notification);
    
    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications = _notifications.take(50).toList();
    }

    saveNotifications();
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      saveNotifications();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    saveNotifications();
    notifyListeners();
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    saveNotifications();
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    saveNotifications();
    notifyListeners();
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Smart notification methods
  void sendShoppingReminder() {
    addNotification(
      'Shopping Reminder',
      'Don\'t forget to check your grocery list!',
      NotificationType.reminder,
    );
  }

  void sendLowStockAlert(String itemName) {
    addNotification(
      'Low Stock Alert',
      'You might be running low on $itemName',
      NotificationType.alert,
    );
  }

  void sendSyncComplete() {
    addNotification(
      'Sync Complete',
      'Your shopping list has been synchronized successfully',
      NotificationType.info,
    );
  }

  void sendOfflineMode() {
    addNotification(
      'Offline Mode',
      'You\'re currently offline. Changes will sync when connection is restored.',
      NotificationType.warning,
    );
  }

  void sendBackupComplete() {
    addNotification(
      'Backup Complete',
      'Your data has been backed up successfully',
      NotificationType.success,
    );
  }
}

enum NotificationType {
  info,
  success,
  warning,
  error,
  reminder,
  alert,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.info,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'],
    );
  }
}
