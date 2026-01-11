import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:campuswork/model/notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const _notificationsKey = 'notifications';
  List<AppNotification> _notifications = [];

  Future<void> init() async {
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsData = prefs.getString(_notificationsKey);
      if (notificationsData != null) {
        final List<dynamic> notificationsList = jsonDecode(notificationsData);
        _notifications = notificationsList.map((json) => AppNotification.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
      _notifications = [];
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationsKey, jsonEncode(_notifications.map((n) => n.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save notifications: $e');
    }
  }

  List<AppNotification> getNotificationsByUser(String userId) =>
      _notifications.where((n) => n.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  int getUnreadCountByUser(String userId) =>
      _notifications.where((n) => n.userId == userId && !n.isRead).length;

  Future<bool> addNotification(AppNotification notification) async {
    try {
      _notifications.add(notification);
      await _saveNotifications();
      return true;
    } catch (e) {
      debugPrint('Failed to add notification: $e');
      return false;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
      if (index == -1) return false;

      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      return true;
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead(String userId) async {
    try {
      for (var i = 0; i < _notifications.length; i++) {
        if (_notifications[i].userId == userId && !_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      await _saveNotifications();
      return true;
    } catch (e) {
      debugPrint('Failed to mark all notifications as read: $e');
      return false;
    }
  }

  Future<void> createLikeNotification(String projectOwnerId, String likerName, String projectName, String projectId) async {
    final notification = AppNotification(
      notificationId: const Uuid().v4(),
      userId: projectOwnerId,
      title: 'Nouveau like',
      message: '$likerName a aimé votre projet "$projectName"',
      type: NotificationType.like,
      relatedId: projectId,
      createdAt: DateTime.now(),
    );
    await addNotification(notification);
  }

  Future<void> createCommentNotification(String projectOwnerId, String commenterName, String projectName, String projectId) async {
    final notification = AppNotification(
      notificationId: const Uuid().v4(),
      userId: projectOwnerId,
      title: 'Nouveau commentaire',
      message: '$commenterName a commenté votre projet "$projectName"',
      type: NotificationType.comment,
      relatedId: projectId,
      createdAt: DateTime.now(),
    );
    await addNotification(notification);
  }
  Future<void> createNotification(String receiverId, String senderId) async {
    final notification = AppNotification(
      notificationId: const Uuid().v4(),
      userId: receiverId,
      title: 'Nouveau message',
      message: '$receiverId vous avez reçu un message de "$senderId"',
      type: NotificationType.message_,
      relatedId: senderId,
      createdAt: DateTime.now(),
    );
    await addNotification(notification);
  }


  Future<void> createEvaluationNotification(String studentId, String projectName, double grade, String projectId) async {
    final notification = AppNotification(
      notificationId: const Uuid().v4(),
      userId: studentId,
      title: 'Projet évalué',
      message: 'Votre projet "$projectName" a été évalué. Note: $grade/20',
      type: NotificationType.evaluation,
      relatedId: projectId,
      createdAt: DateTime.now(),
    );
    await addNotification(notification);
  }

  Future<void> createApprovalNotification(String userId, bool approved) async {
    final notification = AppNotification(
      notificationId: const Uuid().v4(),
      userId: userId,
      title: approved ? 'Compte approuvé' : 'Compte rejeté',
      message: approved
          ? 'Votre compte a été approuvé. Vous pouvez maintenant vous connecter.'
          : 'Votre demande d\'inscription a été rejetée.',
      type: NotificationType.approval,
      createdAt: DateTime.now(),
    );
    await addNotification(notification);
  }
}
