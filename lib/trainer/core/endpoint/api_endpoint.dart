class ApiEndpoint {
  static const String baseUrl =
      "http://10.10.26.235:8000/api/v1"; // e.g. https://api.trainup.com

  static const String signup = "/auth/user/signup";
  static const String verifyEmail = "/auth/user/verify-email";
  static const String resendCode = "/auth/user/resend-code";
  static const String signin = "/auth/user/signin";
  static const String forgotPassword = "/auth/user/forgot-password";
  static const String verifyOtp = "/auth/user/verify-otp";
  static const String setPassword = "/auth/user/set-password";

  //Profile

  static const String profile = "/auth/user/profile";
}

class ChatEndpoint {
  static const String baseUrl = "https://8379-103-186-20-2.ngrok-free.app";

  static const String conversations =
      "http://10.10.26.235:8000/api/v1/chat/conversations";

  static String messages(String peerId) =>
      "http://10.10.26.235:8000/api/v1/chat/messages/$peerId";

  static String? resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return 'http://10.10.26.235:8000$normalizedPath';
  }
}
