import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../core/local_storage/user_info.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.put(ProfileController());

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final RxBool isLoading = false.obs;

  // ─── Fields populated from GET /auth/user/profile ────────────────
  final nameController    = TextEditingController();
  final bioController     = TextEditingController();
  final addressController = TextEditingController();

  final RxString email      = ''.obs;
  final RxString role       = ''.obs;
  final RxString status     = ''.obs;
  final RxBool   isVerified = false.obs;
  final RxString profileImageUrl = ''.obs; // `profile` field from API, if it's a URL

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(
        ApiEndpoint.profile,
        requiresAuth: true, // sends saved token as Authorization: Bearer <token>
      );

      final data = response?['data'];
      if (data != null) {
        nameController.text    = data['name'] ?? '';
        bioController.text     = data['bio'] ?? '';
        addressController.text = data['address'] ?? '';
        email.value             = data['email'] ?? '';
        role.value               = data['role'] ?? '';
        status.value             = data['status'] ?? '';
        isVerified.value         = data['isVerified'] ?? false;
        profileImageUrl.value    = data['profile'] ?? '';

        // keep local session in sync (useful for role-based routing elsewhere)
        await UserInfo.setUser(
          id   : data['id'] ?? '',
          email: data['email'] ?? '',
          name : data['name'] ?? '',
          role : data['role'] ?? '',
        );
      }
    } on UnauthorizedException catch (_) {
      _showError('Session expired. Please log in again.');
      await UserInfo.logout();
      Get.offAllNamed('/login'); // or your RouteName.login
    } on HttpException catch (e) {
      _showError(e.message);
    } catch (e) {
      debugPrint('❌ Fetch profile error: $e');
      _showError('Could not load profile. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // No PUT/PATCH endpoint has been provided yet — this shows a message
  // instead of pretending to save. Replace with a real API call once
  // the update endpoint is available.
  void save() {
    _showInfo('Profile editing isn\'t available yet.');
  }

  void _showError(String message) => _snack(message, Icons.error_outline, Colors.red.shade700);
  void _showInfo(String message) => _snack(message, Icons.info_outline, Colors.blue.shade700);

  void _snack(String message, IconData icon, Color color) {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 50),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    addressController.dispose();
    super.onClose();
  }
}