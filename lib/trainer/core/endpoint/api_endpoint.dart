class ApiEndpoint {
  static const String host    = "http://10.10.26.235:8000";
  static const String baseUrl = "$host/api/v1";

  static const String signup         = "/auth/user/signup";
  static const String verifyEmail    = "/auth/user/verify-email";
  static const String resendCode     = "/auth/user/resend-code";
  static const String signin         = "/auth/user/signin";
  static const String forgotPassword = "/auth/user/forgot-password";
  static const String verifyOtp      = "/auth/user/verify-otp";
  static const String setPassword    = "/auth/user/set-password";
  static const String profile        = "/auth/user/profile";
  static const String updateProfile  = "/user/update-profile";
  static const String accountDelete  = "/auth/user/account-delete";
  static const String accountDeleteConfirm = "/auth/user/account-delete-confirm";

  static const String clubList = "$baseUrl/club/list";


  // ─── Notifications ────────────────────────────────────────────
  static const String notifications = "/notification";
  static String notificationRead(String id) => "/notification/read/$id";
  // ─── Trainers ──────────────────────────────────────────────────
  static const String trainerList = "/trainer/list";
  static const String myClubTrainers = "/trainer/my-club-trainers";
  static const String myClubs = "/trainer/my-clubs";
  static const String sendRequestByClubAdmin = "/trainer/send-request-by-club-admin";
  static const String sendRequestByTrainer = "/trainer/send-request-by-trainer";
  static const String trainerAcceptReject = "/trainer/trainer-accept-reject";
  static const String clubAdminAcceptReject = "/trainer/club-admin-accept-reject";
  static const String notificationAcceptRejected = trainerAcceptReject;
  static const String myClubTrainersRequest = "/trainer/my-club-trainers-request";
  static const String myClubsRequest = "/trainer/my-clubs-request";

  //Announcement
  static const String announcements = '/announcement';
  static const String announcementCreate = '/announcement/create';
  static const String announcementUpdate = '/announcement/update';
  // Delete is handled dynamically in controller as /announcement/{id}

  // ─── Teams ────────────────────────────────────────────────────
  static const String team                     = "/team";
  static const String myTeam                   = "/team/my-team";
  static const String teamCreate               = "/team/create";
  static const String teamUpdate               = "/team/update";
  static const String teamAddMember            = "/team/add-member";
  static const String teamJoinRequestByTrainer = "/team/join-request-by-trainer";
  static String teamDetail(String id)          => "/team/$id";
  static String teamDelete(String id)          => "/team/$id";

  /// Server returns relative image paths like "/images/xxx.webp" —
  /// images live at the host root (NOT under /api/v1), so we prefix
  /// with `host`, matching ChatEndpoint's working implementation.
  static String? resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$host$normalizedPath';
  }
}

class ChatEndpoint {
  static const String baseUrl = ApiEndpoint.host;

  static const String conversations = "$baseUrl/api/v1/chat/conversations";
  static String messages(String peerId) => "$baseUrl/api/v1/chat/messages/$peerId";

  static String? resolveImageUrl(String? path) => ApiEndpoint.resolveImageUrl(path);
}