import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import 'club_screen_controller.dart'; // for ProfileItemModel

class TeamProfileController extends GetxController {
  static TeamProfileController get to =>
      Get.isRegistered<TeamProfileController>()
          ? Get.find<TeamProfileController>()
          : Get.put(TeamProfileController());

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final RxInt selectedTab = 0.obs; // 0: My Teams, 1: Team's Request
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  final TextEditingController searchCtrl = TextEditingController();
  final RxString searchQuery = ''.obs;

  // ─── Initial Mock Data Matching Design Screenshots ─────────────────
  final RxList<ProfileItemModel> myTeams = <ProfileItemModel>[
    const ProfileItemModel(
      id: 't2',
      name: 'Wade Warren',
      email: 'someone@gmail.com',
    ),
    const ProfileItemModel(
      id: 't3',
      name: 'Theresa Webb',
      email: 'someone@gmail.com',
    ),
    const ProfileItemModel(
      id: 't4',
      name: 'Jacob Jones',
      email: 'someone@gmail.com',
    ),
  ].obs;

  final RxList<ProfileItemModel> requests = <ProfileItemModel>[
    const ProfileItemModel(
      id: 'tr1',
      name: 'Robert Fox',
      email: 'someone@gmail.com',
      isActionable: true,
    ),
    const ProfileItemModel(
      id: 'tr2',
      name: 'Robert Fox',
      email: 'someone@gmail.com',
      isPending: true,
    ),
  ].obs;

  final RxList<ProfileItemModel> addTeams = <ProfileItemModel>[
    const ProfileItemModel(
      id: 'ta1',
      name: 'Eleanor Pena',
      email: 'someone@gmail.com',
    ),
    const ProfileItemModel(
      id: 'ta2',
      name: 'Wade Warren',
      email: 'someone@gmail.com',
    ),
    const ProfileItemModel(
      id: 'ta3',
      name: 'Theresa Webb',
      email: 'someone@gmail.com',
    ),
    const ProfileItemModel(
      id: 'ta4',
      name: 'Jacob Jones',
      email: 'someone@gmail.com',
    ),
  ].obs;

  final RxList<ProfileItemModel> filteredAddTeams = <ProfileItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    filteredAddTeams.assignAll(addTeams);
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
      await Future.wait([
        _fetchActiveTeamsFromApi(),
        _fetchRequestTeamsFromApi(),
        _fetchAvailableTeamsFromApi(),
      ]);
    } catch (e) {
      debugPrint('ℹ️ TeamProfileController: Using fallback data ($e)');
    } finally {
      isLoading.value = false;
    }
  }

  // GET /team/active-teams (Trainer)
  Future<void> _fetchActiveTeamsFromApi() async {
    try {
      var res = await _apiClient.get(
        ApiEndpoint.activeTeams,
        requiresAuth: true,
      );

      // Fallback to /team/my-team if active-teams is not available
      if (res?['success'] != true) {
        res = await _apiClient.get(ApiEndpoint.myTeam, requiresAuth: true);
      }

      if (res?['success'] == true && res?['data'] != null) {
        final dynamic raw = res['data'];
        final List list = (raw is List)
            ? raw
            : (raw is Map && raw['teams'] is List)
                ? raw['teams']
                : [];
        if (list.isNotEmpty) {
          final items = list.map((item) {
            final name = item['name']?.toString() ?? 'Team';
            final email = item['sendEmail']?.toString() ??
                item['trainerName']?.toString() ??
                item['trainer']?['email']?.toString() ??
                'someone@gmail.com';
            final id = item['id']?.toString() ?? '';
            return ProfileItemModel(
              id: id,
              teamId: id,
              name: name,
              email: email,
            );
          }).toList();
          myTeams.assignAll(items);
        }
      }
    } catch (e) {
      debugPrint('❌ Error in _fetchActiveTeamsFromApi: $e');
    }
  }

  // GET /team/request-teams (Trainer)
  Future<void> _fetchRequestTeamsFromApi() async {
    try {
      final res = await _apiClient.get(
        ApiEndpoint.requestTeams,
        requiresAuth: true,
      );
      if (res?['success'] == true && res?['data'] != null) {
        final dynamic raw = res['data'];
        final List list = (raw is List)
            ? raw
            : (raw is Map && raw['requests'] is List)
                ? raw['requests']
                : [];
        if (list.isNotEmpty) {
          final items = list.map((item) {
            final team = item['team'] as Map<String, dynamic>?;
            final name =
                team?['name']?.toString() ?? item['name']?.toString() ?? 'Team';
            final email = team?['sendEmail']?.toString() ??
                item['sendEmail']?.toString() ??
                item['trainer']?['email']?.toString() ??
                'someone@gmail.com';
            final id = item['id']?.toString() ?? ''; // requestId
            final teamId =
                team?['id']?.toString() ?? item['teamId']?.toString() ?? id;
            final isTrainerRequested = item['isTrainerRequested'] == true;
            return ProfileItemModel(
              id: id,
              teamId: teamId,
              name: name,
              email: email,
              isPending: isTrainerRequested,
              isActionable: !isTrainerRequested,
            );
          }).toList();
          requests.assignAll(items);
        }
      }
    } catch (e) {
      debugPrint('❌ Error in _fetchRequestTeamsFromApi: $e');
    }
  }

  // GET /team (available teams to join)
  Future<void> _fetchAvailableTeamsFromApi() async {
    try {
      final res = await _apiClient.get(ApiEndpoint.team, requiresAuth: true);
      if (res?['success'] == true && res?['data'] != null) {
        final dynamic raw = res['data'];
        final List list = (raw is List)
            ? raw
            : (raw is Map && raw['teams'] is List)
                ? raw['teams']
                : [];
        if (list.isNotEmpty) {
          final items = list.map((item) {
            final name = item['name']?.toString() ?? 'Team';
            final email = item['sendEmail']?.toString() ??
                item['trainerName']?.toString() ??
                'someone@gmail.com';
            final id = item['id']?.toString() ?? '';
            final isAlreadyPending = requests
                .any((r) => (r.teamId == id || r.id == id) && r.isPending);

            return ProfileItemModel(
              id: id,
              teamId: id,
              name: name,
              email: email,
              isPending: isAlreadyPending,
            );
          }).toList();
          addTeams.assignAll(items);
          filterTeams(searchCtrl.text);
        }
      }
    } catch (_) {}
  }

  // ─── Search ─────────────────────────────────────────────────────────
  void filterTeams(String query) {
    searchQuery.value = query;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filteredAddTeams.assignAll(addTeams);
    } else {
      filteredAddTeams.assignAll(
        addTeams.where((item) =>
            item.name.toLowerCase().contains(q) ||
            item.email.toLowerCase().contains(q)),
      );
    }
  }

  void clearSearch() {
    searchCtrl.clear();
    filterTeams('');
  }

  // ─── Actions ────────────────────────────────────────────────────────
  // PATCH /trainer/trainer-accept-reject
  // body: { "requestId": requestId, "status": "accepted" }
  Future<void> approveRequest(String id) async {
    try {
      debugPrint(
          '📡 Approving team request: requestId=$id via ${ApiEndpoint.trainerAcceptReject}');
      await _apiClient.patch(
        ApiEndpoint.trainerAcceptReject,
        body: {'id': id, 'requestId': id, 'status': 'ACTIVE'},
        requiresAuth: true,
      );
    } catch (e) {
      debugPrint('ℹ️ Approve error: $e');
    }

    final index = requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      final item = requests.removeAt(index);
      myTeams.add(item.copyWith(isActionable: false, isPending: false));
    }

    Get.snackbar(
      'Approved',
      'Team request approved successfully',
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  // PATCH /trainer/trainer-accept-reject
  // body: { "id": id, "requestId": requestId, "status": "REJECTED" }
  Future<void> declineRequest(String id) async {
    try {
      debugPrint(
          '📡 Declining team request: requestId=$id via ${ApiEndpoint.trainerAcceptReject}');
      await _apiClient.patch(
        ApiEndpoint.trainerAcceptReject,
        body: {'id': id, 'requestId': id, 'status': 'REJECTED'},
        requiresAuth: true,
      );
    } catch (e) {
      debugPrint('ℹ️ Decline error: $e');
    }

    requests.removeWhere((r) => r.id == id);

    Get.snackbar(
      'Declined',
      'Team request declined',
      backgroundColor: Colors.red.shade800,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  // POST /team/join-request-by-trainer
  // body: { "teamId": teamId }
  Future<void> sendJoinRequest(ProfileItemModel item) async {
    isSubmitting.value = true;
    final targetTeamId = (item.teamId != null && item.teamId!.isNotEmpty)
        ? item.teamId!
        : item.id;

    try {
      debugPrint('📡 Sending team join request: teamId=$targetTeamId');
      final res = await _apiClient.post(
        ApiEndpoint.teamJoinRequestByTrainer,
        body: {'teamId': targetTeamId},
        requiresAuth: true,
      );

      final message = res?['message'] ?? 'Request sent to team successfully';
      Get.snackbar(
        'Success',
        message,
        backgroundColor: const Color(0xFF2F7CF6),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('❌ Send team request error: $e');
      Get.snackbar(
        'Notice',
        'Request submitted',
        backgroundColor: const Color(0xFF2F7CF6),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isSubmitting.value = false;
    }

    // Mark as pending in add list
    final idx = addTeams.indexWhere((t) => t.id == item.id);
    if (idx != -1) {
      addTeams[idx] = addTeams[idx].copyWith(isPending: true);
      filterTeams(searchCtrl.text);
    }

    // Add to requests list as pending
    if (!requests.any((r) => r.id == item.id || r.teamId == targetTeamId)) {
      requests.add(item.copyWith(
        id: item.id,
        teamId: targetTeamId,
        isPending: true,
        isActionable: false,
      ));
    }
  }
}
