import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  static const _kToken       = 'access_token';
  static const _kUserId      = 'user_id';
  static const _kUserEmail   = 'user_email';
  static const _kUserName    = 'user_name';
  static const _kUserRole    = 'user_role';
  static const _kPendingEmail = 'pending_signup_email';
  static const _kResetEmail  = 'reset_email';
  static const _kResetOtp    = 'reset_otp';

  // ─── Access Token ──────────────────────────────────────────────
  static Future<void> setAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ─── User profile (set after verify-email / signin / set-password) ──
  static Future<void> setUser({
    required String id,
    required String email,
    required String name,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserId, id);
    await prefs.setString(_kUserEmail, email);
    await prefs.setString(_kUserName, name);
    await prefs.setString(_kUserRole, role);
  }

  static Future<String?> getUserId() async =>
      (await SharedPreferences.getInstance()).getString(_kUserId);
  static Future<String?> getUserEmail() async =>
      (await SharedPreferences.getInstance()).getString(_kUserEmail);
  static Future<String?> getUserName() async =>
      (await SharedPreferences.getInstance()).getString(_kUserName);
  static Future<String?> getUserRole() async =>
      (await SharedPreferences.getInstance()).getString(_kUserRole);

  // ─── Pending signup email (before verify-email) ─────────────────
  static Future<void> setPendingSignupEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPendingEmail, email);
  }
  static Future<String?> getPendingSignupEmail() async =>
      (await SharedPreferences.getInstance()).getString(_kPendingEmail);

  // ─── Forgot-password flow — email + otp needed together for set-password
  static Future<void> setResetEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kResetEmail, email);
  }
  static Future<String?> getResetEmail() async =>
      (await SharedPreferences.getInstance()).getString(_kResetEmail);

  static Future<void> setResetOtp(String otp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kResetOtp, otp);
  }
  static Future<String?> getResetOtp() async =>
      (await SharedPreferences.getInstance()).getString(_kResetOtp);

  static Future<void> clearResetFlow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kResetEmail);
    await prefs.remove(_kResetOtp);
  }
// user_info.dart-তে যোগ করো
  static Future<String?> getUserId() async =>
      (await SharedPreferences.getInstance()).getString(_kUserId);
  // ─── Logout ───────────────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUserId);
    await prefs.remove(_kUserEmail);
    await prefs.remove(_kUserName);
    await prefs.remove(_kUserRole);
  }
}