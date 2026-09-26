import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../core/local_storage/user_info.dart';
import '../../routes/route_name.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.put(ProfileController());

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);
  final ImagePicker _picker = ImagePicker();

  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;

  // ─── Input Controllers ──────────────────────────────────────────
  final nameController    = TextEditingController();
  final bioController     = TextEditingController();
  final addressController = TextEditingController();

  // ─── Reactive Profile Fields ────────────────────────────────────
  final RxString name            = ''.obs;
  final RxString email           = ''.obs;
  final RxString role            = ''.obs;
  final RxString status          = ''.obs;
  final RxBool   isVerified      = false.obs;
  final RxString profileImageUrl = ''.obs;

  // ─── Selected Local Image for Upload ────────────────────────────
  final Rx<File?> selectedImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  // ─── Pick Image (Camera or Gallery) ─────────────────────────────
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        debugPrint('📸 Selected image path: ${pickedFile.path}');
      }
    } catch (e) {
      debugPrint('❌ Pick image error: $e');
      _showError('Failed to pick image');
    }
  }

  // ─── 1. GET User Profile ────────────────────────────────────────
  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(
        ApiEndpoint.profile,
        requiresAuth: true,
      );

      final data = response?['data'];
      if (data != null) {
        name.value              = data['name'] ?? '';
        nameController.text    = data['name'] ?? '';
        bioController.text     = data['bio'] ?? '';
        addressController.text = data['address'] ?? '';
        email.value             = data['email'] ?? '';
        role.value               = data['role'] ?? '';
        status.value             = data['status'] ?? '';
        isVerified.value         = data['isVerified'] ?? false;
        profileImageUrl.value    = data['profile'] ?? '';

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
      Get.offAllNamed(RouteName.login);
    } on HttpException catch (e) {
      _showError(e.message);
    } catch (e) {
      debugPrint('❌ Fetch profile error: $e');
      _showError('Could not load profile. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 2. PUT Update Profile (form-data) ──────────────────────────
  Future<bool> updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      _showError('Name cannot be empty');
      return false;
    }

    isUpdating.value = true;
    try {
      final fields = {
        'name': nameController.text.trim(),
        'bio': bioController.text.trim(),
        'address': addressController.text.trim(),
      };

      final Map<String, File> files = {};
      if (selectedImage.value != null) {
        files['image'] = selectedImage.value!;
      }

      debugPrint('📤 Updating profile fields: $fields, files: ${files.keys}');

      final response = await _apiClient.multipart(
        ApiEndpoint.updateProfile,
        method: 'PUT',
        fields: fields,
        files: files.isNotEmpty ? files : null,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        final data = response['data'];
        if (data != null) {
          name.value              = data['name'] ?? nameController.text;
          nameController.text    = data['name'] ?? nameController.text;
          bioController.text     = data['bio'] ?? bioController.text;
          addressController.text = data['address'] ?? addressController.text;
          profileImageUrl.value    = data['profile'] ?? profileImageUrl.value;
          email.value             = data['email'] ?? email.value;
          role.value               = data['role'] ?? role.value;
          status.value             = data['status'] ?? status.value;

          await UserInfo.setUser(
            id   : data['id'] ?? '',
            email: data['email'] ?? email.value,
            name : data['name'] ?? nameController.text,
            role : data['role'] ?? role.value,
          );
        }

        selectedImage.value = null; // reset picked file
        _showSuccess(response?['message'] ?? 'Profile updated successfully');
        Get.back();
        return true;
      }
      return false;
    } on HttpException catch (e) {
      _showError(e.message);
      return false;
    } catch (e) {
      debugPrint('❌ Update profile error: $e');
      _showError('Failed to update profile. Please try again.');
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // ─── 3. POST Request Delete Account ─────────────────────────────
  Future<void> requestDeleteAccount() async {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF161E30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete your account? A verification code (OTP) will be sent to your email to confirm deletion.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // close confirm dialog
              await _sendDeleteAccountRequest();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Send Code', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendDeleteAccountRequest() async {
    isDeleting.value = true;
    try {
      final response = await _apiClient.post(
        ApiEndpoint.accountDelete,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        _showSuccess(response?['message'] ?? 'Verification code sent to your email');
        _showDeleteConfirmDialog();
      }
    } on HttpException catch (e) {
      _showError(e.message);
    } catch (e) {
      debugPrint('❌ Delete account request error: $e');
      _showError('Could not process delete request. Please try again.');
    } finally {
      isDeleting.value = false;
    }
  }

  // ─── 4. POST Confirm Delete Account with OTP ────────────────────
  void _showDeleteConfirmDialog() {
    final otpController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF161E30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Account Deletion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the OTP code received in your email to permanently delete your account:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 4),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter OTP',
                hintStyle: const TextStyle(color: Colors.white38, letterSpacing: 0),
                filled: true,
                fillColor: const Color(0xFF0F1522),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = otpController.text.trim();
              if (code.isEmpty) {
                _showError('Please enter the OTP code');
                return;
              }
              Get.back();
              await _confirmDeleteAccount(code);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(String otp) async {
    isDeleting.value = true;
    try {
      final body = {
        "otp": int.tryParse(otp) ?? otp,
      };

      final response = await _apiClient.post(
        ApiEndpoint.accountDeleteConfirm,
        body: body,
        requiresAuth: true,
      );

      if (response?['success'] == true) {
        _showSuccess(response?['message'] ?? 'Account deleted successfully');
        await UserInfo.logout();
        Get.offAllNamed(RouteName.wellcome1);
      }
    } on HttpException catch (e) {
      _showError(e.message);
    } catch (e) {
      debugPrint('❌ Confirm delete error: $e');
      _showError('Failed to confirm deletion. Please try again.');
    } finally {
      isDeleting.value = false;
    }
  }

  // ─── Alerts & SnackBar ──────────────────────────────────────────
  void _showError(String message) => _snack(message, Icons.error_outline, Colors.red.shade700);
  void _showSuccess(String message) => _snack(message, Icons.check_circle_outline, Colors.green.shade700);

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