import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import 'notification_model.dart';
import '../../core/local_storage/user_info.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.put(NotificationController());

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool showUnreadOnly = false.obs;

  int get unreadCount {
    notifications.value; // ensure Obx registers listener even when list is empty
    return notifications.where((n) => !n.isRead).length;
  }

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final endpoint = showUnreadOnly.value
          ? '${ApiEndpoint.notifications}?isRead=false'
          : ApiEndpoint.notifications;

      debugPrint('📡 Fetching notifications: ${ApiEndpoint.baseUrl}$endpoint');

      final response = await _apiClient.get(endpoint, requiresAuth: true);

      debugPrint('📩 Notification response: $response');

      final rawList = (response?['data'] as List?) ?? [];
      debugPrint('📦 Raw notification count: ${rawList.length}');

      final parsed = <NotificationModel>[];
      for (final item in rawList) {
        try {
          parsed.add(NotificationModel.fromJson(item as Map<String, dynamic>));
        } catch (e) {
          debugPrint('⚠️ Skipped malformed notification: $item — $e');
        }
      }
      parsed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifications.assignAll(parsed);
      debugPrint('✅ Parsed notification count: ${parsed.length}');
    } on UnauthorizedException catch (e) {
      debugPrint('❌ Unauthorized (401) fetching notifications: ${e.message}');
      Get.snackbar('Session issue', 'Please log in again to see notifications',
          backgroundColor: const Color(0xFF1A2236), colorText: Colors.white);
    } on HttpException catch (e) {
      debugPrint('❌ Fetch notifications failed [${e.statusCode}]: ${e.message} | body: ${e.body}');
    } catch (e) {
      debugPrint('❌ Fetch notifications error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(bool unreadOnly) {
    if (showUnreadOnly.value == unreadOnly) return;
    showUnreadOnly.value = unreadOnly;
    fetchNotifications();
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    final wasRead = index != -1 ? notifications[index].isRead : null;
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
    }

    try {
      await _apiClient.patch(ApiEndpoint.notificationRead(id), requiresAuth: true);
      if (showUnreadOnly.value) {
        notifications.removeWhere((n) => n.id == id);
      }
    } catch (e) {
      debugPrint('❌ Mark as read failed: $e');
      if (index != -1 && wasRead != null) {
        notifications[index].isRead = wasRead;
        notifications.refresh();
      }
    }
  }

  // ✅ METHOD FOR APPROVE/REJECT (Matching Postman)
  Future<void> handleNotificationAction({
    required String notificationId,
    required String referenceId,
    required String status, // "ACTIVE" or "REJECTED"
  }) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    // Optimistic update
    final previousActionDone = notifications[index].isActionDone;
    notifications[index].isActionDone = true;
    notifications.refresh();

    try {
      final role = await UserInfo.getUserRole();
      // Per Postman: 
      // Admin accepts trainer request via /trainer/trainer-accept-reject
      // Trainer accepts club admin request via /trainer/club-admin-accept-reject
      final endpoint = (role == 'TRAINER')
          ? ApiEndpoint.clubAdminAcceptReject
          : ApiEndpoint.trainerAcceptReject;

      // Body in Postman expects 'id' as the request/reference ID
      final actionId = referenceId.isNotEmpty ? referenceId : notificationId;
      final body = {
        "id": actionId,
        "status": status,
      };

      debugPrint('📤 Sending action to $endpoint: $body');

      await _apiClient.patch(
        endpoint,
        body: body,
        requiresAuth: true,
      );

      debugPrint('✅ Action successful');

      // Also mark this notification as read
      await markAsRead(notificationId);

      Get.snackbar(
        status == 'ACTIVE' ? 'Accepted' : 'Declined',
        status == 'ACTIVE' ? 'Request accepted successfully' : 'Request declined',
        backgroundColor: status == 'ACTIVE' ? Colors.green.shade700 : Colors.red.shade700,
        colorText: Colors.white,
      );

      // Remove from list if on Unread tab or refresh logic as needed
      if (showUnreadOnly.value) {
        notifications.removeWhere((n) => n.id == notificationId);
      }
    } catch (e) {
      debugPrint('❌ Action failed: $e');
      // Revert optimistic update on failure
      notifications[index].isActionDone = previousActionDone;
      notifications.refresh();

      Get.snackbar(
        'Error',
        'Failed to process request. Please try again.',
        backgroundColor: const Color(0xFF1A2236),
        colorText: Colors.white,
      );
    }
  }

  String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}