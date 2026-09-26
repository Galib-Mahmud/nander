import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../core/local_storage/user_info.dart';
import 'team_model.dart';

class TeamController extends GetxController {
  static TeamController get to => Get.put(TeamController());

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);
  final ImagePicker _picker = ImagePicker();

  final RxList<TeamModel> teams = <TeamModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isClubAdmin = false.obs;

  // Selected image for adding/editing team
  final Rx<File?> selectedImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    checkUserRole();
    fetchTeams();
  }

  Future<void> checkUserRole() async {
    final role = await UserInfo.getUserRole();
    isClubAdmin.value = (role == 'CLUB_ADMIN');
    debugPrint('👥 TeamController - User role: $role, isClubAdmin: ${isClubAdmin.value}');
  }

  // ─── Pick Image for Team ──────────────────────────────────────────
  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        selectedImage.value = File(picked.path);
      }
    } catch (e) {
      debugPrint('❌ Pick image error: $e');
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  void clearSelectedImage() {
    selectedImage.value = null;
  }

  // ─── GET All Teams ────────────────────────────────────────────────
  Future<void> fetchTeams() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(ApiEndpoint.team, requiresAuth: true);

      if (response?['success'] == true) {
        final dynamic raw = response['data'];
        final List<dynamic> list = (raw is List)
            ? raw
            : (raw is Map && raw['teams'] is List)
                ? raw['teams']
                : [];

        final parsed = <TeamModel>[];
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            try {
              parsed.add(TeamModel.fromJson(item));
            } catch (e) {
              debugPrint('⚠️ Error parsing team item: $e');
            }
          }
        }

        teams.assignAll(parsed);
        debugPrint('✅ Loaded ${teams.length} teams');
      }
    } catch (e) {
      debugPrint('❌ Fetch teams error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── GET Single Team ──────────────────────────────────────────────
  Future<TeamModel?> fetchSingleTeam(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoint.teamDetail(id), requiresAuth: true);
      if (response?['success'] == true && response['data'] is Map<String, dynamic>) {
        return TeamModel.fromJson(response['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('❌ Fetch single team error: $e');
    }
    return null;
  }

  // ─── POST Create Team (form-data) ─────────────────────────────────
  Future<bool> createTeam({
    required String name,
    required String bio,
    required String address,
    required String sendEmail,
    required String trainerName,
    File? imageFile,
  }) async {
    if (name.trim().isEmpty) {
      Get.snackbar('Error', 'Team name is required');
      return false;
    }

    isSubmitting.value = true;
    try {
      final fields = {
        'name': name.trim(),
        'bio': bio.trim(),
        'address': address.trim(),
        'sendEmail': sendEmail.trim(),
        'trainerName': trainerName.trim(),
      };

      final fileToUpload = imageFile ?? selectedImage.value;
      final Map<String, File> files = {};
      if (fileToUpload != null) {
        files['image'] = fileToUpload;
      }

      debugPrint('📤 Creating team: $fields, files: ${files.keys}');

      final response = await _apiClient.multipart(
        ApiEndpoint.teamCreate,
        method: 'POST',
        fields: fields,
        files: files.isNotEmpty ? files : null,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        selectedImage.value = null;
        Get.back(); // close screen
        Get.snackbar(
          'Success',
          response?['message'] ?? 'Team created successfully',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
        await fetchTeams();
        return true;
      }
      return false;
    } on HttpException catch (e) {
      debugPrint('❌ Create team error: $e');
      Get.snackbar('Error', e.message, backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } catch (e) {
      debugPrint('❌ Create team error: $e');
      Get.snackbar('Error', 'Failed to create team', backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── PATCH Update Team (form-data) ────────────────────────────────
  Future<bool> updateTeam({
    required String id,
    required String name,
    required String bio,
    required String address,
    required String sendEmail,
    required String trainerName,
    File? imageFile,
  }) async {
    if (name.trim().isEmpty) {
      Get.snackbar('Error', 'Team name is required');
      return false;
    }

    isSubmitting.value = true;
    try {
      final fields = {
        'id': id,
        'name': name.trim(),
        'bio': bio.trim(),
        'address': address.trim(),
        'sendEmail': sendEmail.trim(),
        'trainerName': trainerName.trim(),
      };

      final fileToUpload = imageFile ?? selectedImage.value;
      final Map<String, File> files = {};
      if (fileToUpload != null) {
        files['image'] = fileToUpload;
      }

      debugPrint('📤 Updating team: $fields, files: ${files.keys}');

      final response = await _apiClient.multipart(
        ApiEndpoint.teamUpdate,
        method: 'PATCH',
        fields: fields,
        files: files.isNotEmpty ? files : null,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        selectedImage.value = null;
        Get.back();
        Get.snackbar(
          'Success',
          response?['message'] ?? 'Team updated successfully',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
        await fetchTeams();
        return true;
      }
      return false;
    } on HttpException catch (e) {
      debugPrint('❌ Update team error: $e');
      Get.snackbar('Error', e.message, backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } catch (e) {
      debugPrint('❌ Update team error: $e');
      Get.snackbar('Error', 'Failed to update team', backgroundColor: Colors.red.shade800, colorText: Colors.white);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── DELETE Team ──────────────────────────────────────────────────
  Future<bool> deleteTeam(String id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoint.teamDelete(id), requiresAuth: true);
      if (response?['success'] == true) {
        teams.removeWhere((t) => t.id == id);
        Get.snackbar(
          'Deleted',
          response?['message'] ?? 'Team deleted successfully',
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Delete team error: $e');
      Get.snackbar('Error', 'Failed to delete team');
      return false;
    }
  }
}
