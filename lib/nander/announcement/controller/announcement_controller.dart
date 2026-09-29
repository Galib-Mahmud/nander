import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../core/local_storage/user_info.dart';
import 'announcement_model.dart';

class AnnouncementController extends GetxController {
  static AnnouncementController get to => Get.put(AnnouncementController());

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final RxList<AnnouncementModel> announcements = <AnnouncementModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isAdmin = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAdminRole();
    fetchAnnouncements();
  }

  /// Checks if current user has the CLUB_ADMIN role based on persistent local storage
  Future<void> checkAdminRole() async {
    final role = await UserInfo.getUserRole();
    isAdmin.value = (role == 'CLUB_ADMIN');
    debugPrint('📢 Current user role: $role, isAdmin: ${isAdmin.value}');
  }

  /// Fetches all announcements from the backend and safely parses them
  Future<void> fetchAnnouncements() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(ApiEndpoint.announcements, requiresAuth: true);

      if (response?['success'] == true) {
        final dynamic rawData = response['data'];
        final List<dynamic> list = (rawData is List)
            ? rawData
            : (rawData is Map && rawData['announcements'] is List)
                ? rawData['announcements']
                : [];

        final parsed = <AnnouncementModel>[];
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            try {
              parsed.add(AnnouncementModel.fromJson(item));
            } catch (e) {
              debugPrint('⚠️ Error parsing announcement item: $item — $e');
            }
          }
        }

        // Sort by newest first
        parsed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        announcements.assignAll(parsed);
        debugPrint('✅ Loaded ${announcements.length} announcements');
      }
    } catch (e) {
      debugPrint('❌ Fetch announcements error: $e');
      Get.snackbar(
        'Error',
        'Failed to load announcements',
        backgroundColor: const Color(0xFF1A2236),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new announcement (POST /announcement/create)
  Future<bool> createAnnouncement(String title, String description) async {
    isSubmitting.value = true;
    try {
      final body = {
        "title": title.trim(),
        "description": description.trim(),
      };
      final response = await _apiClient.post(
        ApiEndpoint.announcementCreate,
        body: body,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        Get.back(); // Go back to list
        Get.snackbar(
          'Success',
          response?['message'] ?? 'Announcement created',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
        await fetchAnnouncements(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Create announcement error: $e');
      Get.snackbar(
        'Error',
        'Failed to create announcement',
        backgroundColor: const Color(0xFF1A2236),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Update an existing announcement (PATCH /announcement/update)
  Future<bool> updateAnnouncement(String id, String title, String description) async {
    isSubmitting.value = true;
    try {
      final body = {
        "id": id,
        "title": title.trim(),
        "description": description.trim(),
      };
      final response = await _apiClient.patch(
        ApiEndpoint.announcementUpdate,
        body: body,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        Get.back();
        Get.snackbar(
          'Success',
          response?['message'] ?? 'Announcement updated',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
        await fetchAnnouncements();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Update announcement error: $e');
      Get.snackbar(
        'Error',
        'Failed to update announcement',
        backgroundColor: const Color(0xFF1A2236),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Delete an announcement (DELETE /announcement/:id)
  Future<bool> deleteAnnouncement(String id) async {
    try {
      final endpoint = '${ApiEndpoint.announcements}/$id';
      final response = await _apiClient.delete(endpoint, requiresAuth: true);

      if (response?['success'] == true) {
        announcements.removeWhere((a) => a.id == id);
        Get.snackbar(
          'Deleted',
          response?['message'] ?? 'Announcement removed',
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Delete announcement error: $e');
      Get.snackbar(
        'Error',
        'Failed to delete announcement',
        backgroundColor: const Color(0xFF1A2236),
        colorText: Colors.white,
      );
      return false;
    }
  }
}