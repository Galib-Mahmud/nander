import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';

class ProfileItemModel {
  final String id;
  final String name;
  final String email;
  final bool isPending;
  final bool isActionable;
  final String? clubAdminId;
  final String? teamId;

  const ProfileItemModel({
    required this.id,
    required this.name,
    required this.email,
    this.isPending = false,
    this.isActionable = false,
    this.clubAdminId,
    this.teamId,
  });

  /// Id the join request is sent to (club admin id, falls back to id).
  String get targetId =>
      (clubAdminId != null && clubAdminId!.isNotEmpty) ? clubAdminId! : id;

  ProfileItemModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? isPending,
    bool? isActionable,
    String? clubAdminId,
    String? teamId,
  }) {
    return ProfileItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isPending: isPending ?? this.isPending,
      isActionable: isActionable ?? this.isActionable,
      clubAdminId: clubAdminId ?? this.clubAdminId,
      teamId: teamId ?? this.teamId,
    );
  }
}

class ClubScreenController extends GetxController {
  static ClubScreenController get to => Get.isRegistered<ClubScreenController>()
      ? Get.find<ClubScreenController>()
      : Get.put(ClubScreenController());

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final RxInt selectedTab = 0.obs; // 0: My Clubs, 1: Club's Request
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingFindClubs = false.obs;
  final RxBool isLoadingMyClubs = false.obs;
  final RxBool isLoadingRequests = false.obs;

  /// Request ids an approve / decline call is running for (blocks double taps).
  final RxSet<String> processingRequestIds = <String>{}.obs;

  /// Club ids a request is currently being sent to (disables the button).
  final RxSet<String> sendingClubIds = <String>{}.obs;

  /// Club ids this trainer already sent a request to. Kept locally so the
  /// button stays "Pending Request" even if /trainer/find-club does not flag it.
  final RxSet<String> pendingClubIds = <String>{}.obs;

  final TextEditingController searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Filled from GET /trainer/my-clubs ("My Clubs" tab).
  final RxList<ProfileItemModel> myClubs = <ProfileItemModel>[].obs;

  // Filled from GET /trainer/my-clubs-request ("Club's Request" tab).
  final RxList<ProfileItemModel> requests = <ProfileItemModel>[].obs;

  // Filled from GET /trainer/find-club (no mock data, so an empty or failed
  // response never shows fake clubs).
  final RxList<ProfileItemModel> addClubs = <ProfileItemModel>[].obs;

  final RxList<ProfileItemModel> filteredAddClubs = <ProfileItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredAddClubs.assignAll(addClubs);
    fetchData();
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  // ─── API Integration ────────────────────────────────────────────────
  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      // My clubs + requests first, so find-club can reuse them to mark
      // pending clubs.
      await Future.wait([
        fetchMyClubs(showLoader: false),
        fetchClubRequests(showLoader: false),
      ]);
      await fetchFindClubs(showLoader: false);
    } catch (e) {
      debugPrint('ℹ️ ClubScreenController: Using fallback data ($e)');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Tab data: each tab has its own endpoint ───────────────────────
  /// Refresh both tabs (screen open / pull-to-refresh).
  Future<void> refreshClubTabs() async {
    await Future.wait([
      fetchMyClubs(showLoader: myClubs.isEmpty),
      fetchClubRequests(showLoader: requests.isEmpty),
    ]);
  }

  // GET /trainer/my-clubs  ->  "My Clubs" tab
  Future<void> fetchMyClubs({bool showLoader = true}) async {
    if (showLoader) isLoadingMyClubs.value = true;
    try {
      final res = await _apiClient.get(ApiEndpoint.myClubs, requiresAuth: true);

      if (res?['success'] == true) {
        final items = <ProfileItemModel>[];
        for (final raw in _asList(res['data'])) {
          // The tab lists clubs the trainer already joined. Anything still
          // waiting or rejected belongs to the request tab.
          final status = _statusOf(raw);
          if (status == 'PENDING' || status == 'REJECTED') continue;

          final parsed = _parseClubItem(raw);
          if (parsed != null) items.add(parsed);
        }
        // Always replace, even with an empty list.
        myClubs.assignAll(items);
        debugPrint('✅ my-clubs loaded: ${items.length} clubs');
      } else {
        debugPrint('❌ my-clubs not loaded. Response: $res');
      }
    } catch (e) {
      debugPrint('❌ Error in fetchMyClubs: $e');
    } finally {
      if (showLoader) isLoadingMyClubs.value = false;
    }
  }

  // GET /trainer/my-clubs-request  ->  "Club's Request" tab
  Future<void> fetchClubRequests({bool showLoader = true}) async {
    if (showLoader) isLoadingRequests.value = true;
    try {
      final res = await _apiClient.get(
        ApiEndpoint.myClubsRequest,
        requiresAuth: true,
      );

      if (res?['success'] == true) {
        final items = <ProfileItemModel>[];
        for (final raw in _asList(res['data'])) {
          // Already answered requests do not belong in this tab.
          final status = _statusOf(raw);
          if (status == 'ACTIVE' ||
              status == 'ACCEPTED' ||
              status == 'REJECTED') {
            continue;
          }

          final parsed = _parseClubItem(raw, isRequest: true);
          if (parsed != null) items.add(parsed);
        }
        // Always replace, even with an empty list.
        requests.assignAll(items);
        debugPrint('✅ my-clubs-request loaded: ${items.length} requests');
      } else {
        debugPrint('❌ my-clubs-request not loaded. Response: $res');
      }
    } catch (e) {
      debugPrint('❌ Error in fetchClubRequests: $e');
    } finally {
      if (showLoader) isLoadingRequests.value = false;
    }
  }

  String _statusOf(dynamic raw) {
    if (raw is! Map) return '';
    return (raw['status'] ?? raw['requestStatus'] ?? '')
        .toString()
        .toUpperCase();
  }

  /// Reads one item of /trainer/my-clubs or /trainer/my-clubs-request.
  /// Works for a flat object, or one that nests the club under
  /// `clubAdmin` / `club`.
  /// For requests: `isTrainerRequested == true` means the trainer sent it
  /// (shows "Pending Request"), otherwise the club invited the trainer
  /// (shows Approve / Decline).
  ProfileItemModel? _parseClubItem(dynamic raw, {bool isRequest = false}) {
    if (raw is! Map) return null;
    final item = Map<String, dynamic>.from(raw);

    final nested = item['clubAdmin'] is Map
        ? Map<String, dynamic>.from(item['clubAdmin'] as Map)
        : item['club'] is Map
        ? Map<String, dynamic>.from(item['club'] as Map)
        : item;

    // Record id (for requests this is the requestId used by approve/decline).
    final id = (item['id'] ?? nested['id'] ?? '').toString();
    if (id.isEmpty) return null;

    final clubAdminId = (item['clubAdminId'] ?? nested['id'] ?? id).toString();
    final isTrainerRequested = item['isTrainerRequested'] == true;

    return ProfileItemModel(
      id: id,
      clubAdminId: clubAdminId,
      name: (nested['name'] ?? item['name'] ?? 'Club').toString(),
      email: (nested['email'] ?? item['email'] ?? '').toString(),
      isPending: isRequest && isTrainerRequested,
      isActionable: isRequest && !isTrainerRequested,
    );
  }

  // GET /trainer/find-club
  Future<void> fetchFindClubs({bool showLoader = true}) async {
    if (showLoader) isLoadingFindClubs.value = true;
    try {
      final res =
      await _apiClient.get(ApiEndpoint.findClub, requiresAuth: true);

      if (res?['success'] == true) {
        final items = <ProfileItemModel>[];
        for (final raw in _asList(res['data'])) {
          final parsed = _parseFindClub(raw);
          if (parsed != null) items.add(parsed);
        }
        // Always replace, even with an empty list.
        addClubs.assignAll(items);
        filterClubs(searchCtrl.text);
        debugPrint('✅ find-club loaded: ${items.length} clubs');
      } else {
        debugPrint('❌ find-club not loaded. Response: $res');
      }
    } catch (e) {
      debugPrint('❌ Error in fetchFindClubs: $e');
    } finally {
      if (showLoader) isLoadingFindClubs.value = false;
    }
  }

  /// Accepts a plain list or a map wrapping the list (e.g. { clubs: [...] }).
  List<dynamic> _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final value in data.values) {
        if (value is List) return value;
      }
    }
    return <dynamic>[];
  }

  /// Reads one find-club item. Works for a flat club object, or one that
  /// nests the club under `clubAdmin` / `club`.
  ProfileItemModel? _parseFindClub(dynamic raw) {
    if (raw is! Map) return null;
    final item = Map<String, dynamic>.from(raw);

    final nested = item['clubAdmin'] is Map
        ? Map<String, dynamic>.from(item['clubAdmin'] as Map)
        : item['club'] is Map
        ? Map<String, dynamic>.from(item['club'] as Map)
        : item;

    final id = (nested['id'] ?? item['id'] ?? '').toString();
    if (id.isEmpty) return null;

    final clubAdminId =
    (item['clubAdminId'] ?? nested['id'] ?? id).toString();

    final status = (item['status'] ?? item['requestStatus'] ?? '')
        .toString()
        .toUpperCase();
    final serverPending = item['isPending'] == true ||
        item['isRequested'] == true ||
        item['isTrainerRequested'] == true ||
        item['requestSent'] == true ||
        status == 'PENDING';

    final isPending = serverPending ||
        pendingClubIds.contains(clubAdminId) ||
        requests.any((r) =>
        (r.clubAdminId == clubAdminId || r.id == id) && r.isPending);

    return ProfileItemModel(
      id: id,
      clubAdminId: clubAdminId,
      name: (nested['name'] ?? item['name'] ?? 'Club').toString(),
      email: (nested['email'] ?? item['email'] ?? '').toString(),
      isPending: isPending,
    );
  }

  void _markClubPending(String targetId) {
    final idx = addClubs.indexWhere((c) => c.targetId == targetId);
    if (idx != -1) {
      addClubs[idx] = addClubs[idx].copyWith(isPending: true);
      filterClubs(searchCtrl.text);
    }
  }

  // ─── Search ─────────────────────────────────────────────────────────
  void filterClubs(String query) {
    searchQuery.value = query;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filteredAddClubs.assignAll(addClubs);
    } else {
      filteredAddClubs.assignAll(
        addClubs.where((item) =>
        item.name.toLowerCase().contains(q) ||
            item.email.toLowerCase().contains(q)),
      );
    }
  }

  void clearSearch() {
    searchCtrl.clear();
    filterClubs('');
  }

  // ─── Actions ────────────────────────────────────────────────────────
  // PATCH /trainer/club-admin-accept-reject
  // body: { "id": requestId, "status": "ACTIVE" | "REJECTED" }
  /// Returns true only when the server confirmed the change.
  Future<bool> _respondToRequest(String id, String status) async {
    try {
      debugPrint(
          '📡 Club request $status: id=$id via ${ApiEndpoint.clubAdminAcceptReject}');
      final res = await _apiClient.patch(
        ApiEndpoint.clubAdminAcceptReject,
        body: {'id': id, 'status': status},
        requiresAuth: true,
      );

      if (res?['success'] == true) return true;

      debugPrint('❌ Club request not updated. Response: $res');
      _errorSnack(res?['message']?.toString() ?? 'Failed to process request');
    } on HttpException catch (e) {
      debugPrint('❌ Club request error: ${e.message}');
      _errorSnack(e.message);
    } catch (e) {
      debugPrint('❌ Club request error: $e');
      _errorSnack('Failed to process request');
    }
    return false;
  }

  void _errorSnack(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.shade800,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> approveRequest(String id) async {
    if (processingRequestIds.contains(id)) return;
    processingRequestIds.add(id);
    try {
      if (!await _respondToRequest(id, 'ACTIVE')) return;

      final index = requests.indexWhere((r) => r.id == id);
      if (index != -1) {
        final item = requests.removeAt(index);
        myClubs.add(item.copyWith(isActionable: false, isPending: false));
      }

      Get.snackbar(
        'Approved',
        'Club request approved successfully',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Sync both tabs with the server.
      await refreshClubTabs();
    } finally {
      processingRequestIds.remove(id);
    }
  }

  Future<void> declineRequest(String id) async {
    if (processingRequestIds.contains(id)) return;
    processingRequestIds.add(id);
    try {
      if (!await _respondToRequest(id, 'REJECTED')) return;

      requests.removeWhere((r) => r.id == id);

      Get.snackbar(
        'Declined',
        'Club request declined',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Sync both tabs with the server.
      await refreshClubTabs();
    } finally {
      processingRequestIds.remove(id);
    }
  }

  // POST /trainer/send-request-by-trainer
  // body: { "clubId": clubId }
  Future<void> sendJoinRequest(ProfileItemModel item) async {
    final targetClubId = item.targetId;

    // Already pending, or a request for this club is in flight.
    if (item.isPending || sendingClubIds.contains(targetClubId)) return;

    sendingClubIds.add(targetClubId);
    isSubmitting.value = true;

    try {
      debugPrint('📡 Sending request to club: clubId=$targetClubId');
      final res = await _apiClient.post(
        ApiEndpoint.sendRequestByTrainer,
        body: {'clubId': targetClubId},
        requiresAuth: true,
      );

      if (res?['success'] == true) {
        // Only now is the request really sent -> show Pending.
        pendingClubIds.add(targetClubId);
        _markClubPending(targetClubId);

        // Refresh the "Club's Request" tab from /trainer/my-clubs-request.
        fetchClubRequests(showLoader: false);

        Get.snackbar(
          'Success',
          res?['message'] ?? 'Request sent to club successfully',
          backgroundColor: const Color(0xFF2F7CF6),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Sync with the server. pendingClubIds keeps the badge even if
        // /trainer/find-club does not return a pending flag.
        fetchFindClubs(showLoader: false);
      } else {
        Get.snackbar(
          'Notice',
          res?['message'] ?? 'Failed to send request',
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } on HttpException catch (e) {
      debugPrint('❌ Send request error: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('❌ Send request error: $e');
      Get.snackbar(
        'Error',
        'Failed to send request',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      sendingClubIds.remove(targetClubId);
      isSubmitting.value = false;
    }
  }
}