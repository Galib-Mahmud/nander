import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../core/local_storage/user_info.dart';
import '../../routes/route_name.dart';
import 'club_controller.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.put(AuthController());

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final RxBool isLoading = false.obs;
  /// 'signup' or 'forgot_password' — decides what verifyOtp() does next
  final RxString otpFlowType = 'signup'.obs;

  /// true after forgot-password OTP is verified — tells ResetPasswordScreen
  /// whether its Confirm button should send the OTP (false) or finalize the
  /// new password (true).
  final RxBool resetOtpVerified = false.obs;

  // ─── Login / Signup shared fields (from LoginScreen tabs) ───────
  final nameController           = TextEditingController();
  final emailController          = TextEditingController();
  final passwordController       = TextEditingController();
  final retypePasswordController = TextEditingController();
  final RxString role            = 'CLUB_ADMIN'.obs; // CLUB_ADMIN | TRAINER

  // ─── Forgot password ─────────────────────────────────────────────
  final forgotEmailController = TextEditingController();

  // ─── Reset password ──────────────────────────────────────────────
  final newPasswordController        = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  // ─── OTP (6 digits, matches API) ─────────────────────────────────
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());

  // ──────────────────────────────────────────────────────────────────
  // SIGNUP
  // ──────────────────────────────────────────────────────────────────
  Future<void> signup() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _showError('Please fill all required fields');
      return;
    }
    if (passwordController.text != retypePasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      final body = {
        'name'    : nameController.text.trim(),
        'email'   : emailController.text.trim(),
        'password': passwordController.text,
        'role'    : role.value,
      };

      // ✅ clubAdminId is optional, and only relevant for TRAINER signups
      if (role.value == 'TRAINER') {
        final selectedClub = ClubController.to.selectedClubId.value;
        if (selectedClub.isNotEmpty) {
          body['clubAdminId'] = selectedClub;
        }
      }

      final response = await _apiClient.post(
        ApiEndpoint.signup,
        body: body,
        requiresAuth: false,
      );

      final data = response?['data'];
      await UserInfo.setPendingSignupEmail(data?['email'] ?? emailController.text.trim());

      otpFlowType.value = 'signup';
      _clearOtpFields();
      _showSuccess(response?['message'] ?? 'Signup successful. Check your email for the code.');
      Get.toNamed(RouteName.otp);
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
    } catch (e) {
      debugPrint('❌ Signup error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // VERIFY EMAIL (signup OTP) — this is where the token first arrives
  // ──────────────────────────────────────────────────────────────────
  Future<void> _verifySignupOtp() async {
    final code = _getOtpCode();
    if (code.length < otpControllers.length) {
      _showError('Please enter the complete code');
      return;
    }
    isLoading.value = true;
    try {
      final email = await UserInfo.getPendingSignupEmail();
      final response = await _apiClient.post(
        ApiEndpoint.verifyEmail,
        body: {'email': email, 'otp': int.tryParse(code)},
        requiresAuth: false,
      );

      await _persistSession(response);
      _showSuccess('Email verified successfully');
      await _navigateHome();
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
    } catch (e) {
      debugPrint('❌ Verify email error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // VERIFY OTP — routes based on otpFlowType
  // ──────────────────────────────────────────────────────────────────
  Future<void> verifyOtp() async {
    if (otpFlowType.value == 'signup') {
      await _verifySignupOtp();
    } else {
      await _verifyForgotPasswordOtp();
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // RESEND CODE — shared endpoint for both flows
  // ──────────────────────────────────────────────────────────────────
  Future<void> resendCode() async {
    final email = otpFlowType.value == 'signup'
        ? await UserInfo.getPendingSignupEmail()
        : await UserInfo.getResetEmail();
    if (email == null) return;

    isLoading.value = true;
    try {
      final response = await _apiClient.post(
        ApiEndpoint.resendCode,
        body: {'email': email},
        requiresAuth: false,
      );
      _showSuccess(response?['message'] ?? 'A new code has been sent to your email');
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
    } catch (e) {
      debugPrint('❌ Resend code error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // SIGN IN
  // ──────────────────────────────────────────────────────────────────
  Future<void> login() async {
    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      _showError('Please enter email and password');
      return;
    }
    isLoading.value = true;
    try {
      final response = await _apiClient.post(
        ApiEndpoint.signin,
        body: {
          'email'   : emailController.text.trim(),
          'password': passwordController.text,
        },
        requiresAuth: false,
      );

      await _persistSession(response);
      await _navigateHome();
    } on UnauthorizedException catch (e) {
      _showError(_extractMessage(e.body) ?? 'Invalid email or password');
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
    } catch (e) {
      debugPrint('❌ Login error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // FORGOT PASSWORD — step 1: send OTP to email
  // ──────────────────────────────────────────────────────────────────
  Future<void> forgotPassword() async {
    if (forgotEmailController.text.trim().isEmpty) {
      _showError('Please enter your email address');
      return;
    }
    isLoading.value = true;
    try {
      final response = await _apiClient.post(
        ApiEndpoint.forgotPassword,
        body: {'email': forgotEmailController.text.trim()},
        requiresAuth: false,
      );
      await UserInfo.setResetEmail(forgotEmailController.text.trim());
      otpFlowType.value = 'forgot_password';
      resetOtpVerified.value = false;
      _clearOtpFields();
      _showSuccess(response?['message'] ?? 'A code has been sent to your email');
      Get.toNamed(RouteName.otp);
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
    } catch (e) {
      debugPrint('❌ Forgot password error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── step 2: verify OTP, then go back to ResetPasswordScreen to
  // collect the new password ─────────────────────────────────────
  Future<void> _verifyForgotPasswordOtp() async {
    final code = _getOtpCode();
    if (code.length < otpControllers.length) {
      _showError('Please enter the complete code');
      return;
    }
    isLoading.value = true;
    try {
      final email = await UserInfo.getResetEmail();
      final response = await _apiClient.post(
        ApiEndpoint.verifyOtp,
        body: {'email': email, 'otp': int.tryParse(code)},
        requiresAuth: false,
      );
      // set-password needs the otp again, so hang on to it
      await UserInfo.setResetOtp(code);
      resetOtpVerified.value = true;
      _showSuccess(response?['message'] ?? 'OTP verified');
      Get.offNamed(RouteName.forgotPassword);
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
    } catch (e) {
      debugPrint('❌ Verify reset OTP error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── step 3: finalize the new password ──────────────────────────
  Future<void> setNewPassword() async {
    if (newPasswordController.text.isEmpty || confirmNewPasswordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    if (newPasswordController.text != confirmNewPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }
    if (newPasswordController.text.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }
    final email = await UserInfo.getResetEmail();
    final otp   = await UserInfo.getResetOtp();
    if (email == null || otp == null) {
      _showError('Reset session expired. Please start over.');
      resetOtpVerified.value = false;
      Get.offAllNamed(RouteName.login);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiClient.post(
        ApiEndpoint.setPassword,
        body: {
          'email'   : email,
          'otp'     : int.tryParse(otp),
          'password': newPasswordController.text,
        },
        requiresAuth: false,
      );

      // This endpoint's `data` is a raw token string, not an object
      final token = response?['data'];
      if (token is String && token.isNotEmpty) {
        await UserInfo.setAccessToken(token);
      }

      await UserInfo.clearResetFlow();
      resetOtpVerified.value = false;
      newPasswordController.clear();
      confirmNewPasswordController.clear();
      forgotEmailController.clear();
      _showSuccess(response?['message'] ?? 'Password updated successfully');

      if (token is String && token.isNotEmpty) {
        await _navigateHome();
      } else {
        Get.offAllNamed(RouteName.login);
      }
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
    } catch (e) {
      debugPrint('❌ Set new password error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // SHARED HELPERS
  // ──────────────────────────────────────────────────────────────────
  Future<void> _persistSession(Map<String, dynamic>? response) async {
    final data  = response?['data'];
    final token = data?['token'] as String?;
    final user  = data?['user'] as Map<String, dynamic>?;
    if (token != null) await UserInfo.setAccessToken(token);
    if (user != null) {
      await UserInfo.setUser(
        id   : user['id'] ?? '',
        email: user['email'] ?? '',
        name : user['name'] ?? '',
        role : user['role'] ?? '',
      );
    }
  }

  /// CLUB_ADMIN → home1 (MainScreen1), everyone else (e.g. TRAINER) → home
  Future<void> _navigateHome() async {
    final userRole = await UserInfo.getUserRole();
    Get.offAllNamed(userRole == 'CLUB_ADMIN' ? RouteName.main1 : RouteName.main);
  }

  String _getOtpCode() => otpControllers.map((c) => c.text).join('');

  void _clearOtpFields() {
    for (var c in otpControllers) {
      c.clear();
    }
  }

  String? _extractMessage(String? body) {
    if (body == null || body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('message')) return decoded['message'].toString();
        if (decoded.containsKey('detail')) return decoded['detail'].toString();
      }
    } catch (_) {}
    return null;
  }

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
    emailController.dispose();
    passwordController.dispose();
    retypePasswordController.dispose();
    forgotEmailController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    super.onClose();
  }
}