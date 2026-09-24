import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import 'announcement_model.dart';

class AnnouncementController extends GetxController {
  static AnnouncementController get to => Get.put(AnnouncementController());

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final RxList<AnnouncementModel> announcements = <AnnouncementModel>[].obs;
  final RxBool isLoading = false.obs;

  // Check if current user is admin (You might want to get this from AuthController)
  // For now, assuming you have a way to check role.
  // If you don't have AuthController integrated yet, you can hardcode or fetch user profile.
  final RxBool isAdmin = false.obs;

  @override
  void onInit() {
    super.onInit();
    // TODO: Initialize isAdmin based on your Auth state
    // Example: isAdmin.value = Get.find<AuthController>().user.role == 'CLUB_ADMIN';
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(ApiEndpoint.announcements, requiresAuth: true);

      if (response?['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final parsed = data.map((e) => AnnouncementModel.fromJson(e)).toList();
        // Sort by newest first
        parsed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        announcements.assignAll(parsed);
      }
    } catch (e) {
      debugPrint('❌ Fetch announcements error: $e');
      Get.snackbar('Error', 'Failed to load announcements');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAnnouncement(String title, String description) async {
    try {
      final body = {"title": title, "description": description};
      final response = await _apiClient.post(ApiEndpoint.announcementCreate, body: body, requiresAuth: true);

      if (response?['success'] == true) {
        Get.back(); // Go back to list
        Get.snackbar('Success', 'Announcement created', backgroundColor: Colors.green, colorText: Colors.white);
        fetchAnnouncements(); // Refresh list
      }
    } catch (e) {
      debugPrint('❌ Create announcement error: $e');
      Get.snackbar('Error', 'Failed to create announcement');
    }
  }

  Future<void> updateAnnouncement(String id, String title, String description) async {
    try {
      final body = {"id": id, "title": title, "description": description};
      final response = await _apiClient.patch(ApiEndpoint.announcementUpdate, body: body, requiresAuth: true);

      if (response?['success'] == true) {
        Get.back();
        Get.snackbar('Success', 'Announcement updated', backgroundColor: Colors.green, colorText: Colors.white);
        fetchAnnouncements();
      }
    } catch (e) {
      debugPrint('❌ Update announcement error: $e');
      Get.snackbar('Error', 'Failed to update announcement');
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      // Note: Endpoint is /announcement/{id}, so we append ID manually if not in ApiEndpoint
      final endpoint = '${ApiEndpoint.announcements}/$id';
      final response = await _apiClient.delete(endpoint, requiresAuth: true);

      if (response?['success'] == true) {
        announcements.removeWhere((a) => a.id == id);
        Get.snackbar('Deleted', 'Announcement removed', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('❌ Delete announcement error: $e');
      Get.snackbar('Error', 'Failed to delete announcement');
    }
  }
}